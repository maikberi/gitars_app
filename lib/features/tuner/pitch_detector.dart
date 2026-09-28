import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:record/record.dart';

/// Результат распознавания высоты звука: сама частота и ближайшая нота.
class PitchResult {
  const PitchResult({
    required this.frequency,
    required this.noteName,
    required this.centsOff,
  });

  final double frequency;
  final String noteName;

  /// Отклонение в центах от идеальной частоты ноты: 0 — попадание в ноту,
  /// отрицательное — ниже, положительное — выше.
  final double centsOff;
}

/// Слушает микрофон и определяет частоту основного тона в реальном времени
/// с помощью автокорреляции сигнала (без внешних C/DSP-библиотек).
class PitchDetector {
  static const int sampleRate = 44100;
  static const List<String> _noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _subscription;
  final _controller = StreamController<PitchResult?>.broadcast();

  Stream<PitchResult?> get pitchStream => _controller.stream;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> start() async {
    if (!await hasPermission()) {
      throw StateError('Нет разрешения на использование микрофона');
    }
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
      ),
    );
    _subscription = stream.listen(_onAudioChunk);
  }

  void _onAudioChunk(Uint8List bytes) {
    final samples = _pcm16ToDoubles(bytes);
    final frequency = _detectFrequency(samples, sampleRate);
    if (frequency == null) {
      _controller.add(null);
      return;
    }
    _controller.add(_toNote(frequency));
  }

  List<double> _pcm16ToDoubles(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    final length = bytes.length ~/ 2;
    final samples = List<double>.filled(length, 0);
    for (int i = 0; i < length; i++) {
      final value = byteData.getInt16(i * 2, Endian.little);
      samples[i] = value / 32768.0;
    }
    return samples;
  }

  double? _detectFrequency(List<double> buffer, int sampleRate) {
    final size = buffer.length;
    if (size < 512) return null;

    double rms = 0;
    for (final s in buffer) {
      rms += s * s;
    }
    rms = sqrt(rms / size);
    if (rms < 0.01) return null;

    final minLag = (sampleRate / 800).floor();
    final maxLag = min(size ~/ 2, (sampleRate / 60).ceil());
    double bestCorrelation = 0;
    int bestLag = -1;

    for (int lag = minLag; lag < maxLag; lag++) {
      double correlation = 0;
      for (int i = 0; i < size - lag; i++) {
        correlation += buffer[i] * buffer[i + lag];
      }
      correlation /= (size - lag);
      if (correlation > bestCorrelation) {
        bestCorrelation = correlation;
        bestLag = lag;
      }
    }

    if (bestLag <= 0 || bestCorrelation < 0.003) return null;
    return sampleRate / bestLag;
  }

  PitchResult _toNote(double frequency) {
    final midi = 69 + 12 * (log(frequency / 440) / ln2);
    final roundedMidi = midi.round();
    final centsOff = (midi - roundedMidi) * 100;
    final noteName = _noteNames[((roundedMidi % 12) + 12) % 12];
    return PitchResult(frequency: frequency, noteName: noteName, centsOff: centsOff);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _recorder.stop();
  }

  void dispose() {
    stop();
    _controller.close();
    _recorder.dispose();
  }
}
