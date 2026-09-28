import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'pitch_detector.dart';

class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key});

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  static const _tunings = {
    'Standard E': ['E', 'A', 'D', 'G', 'B', 'E'],
    'Drop D': ['D', 'A', 'D', 'G', 'B', 'E'],
    'DADGAD': ['D', 'A', 'D', 'G', 'A', 'D'],
  };

  final _detector = PitchDetector();
  String _selectedTuning = 'Standard E';
  PitchResult? _lastResult;
  bool _isListening = false;
  String? _error;

  @override
  void dispose() {
    _detector.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _detector.stop();
      setState(() {
        _isListening = false;
        _lastResult = null;
      });
      return;
    }

    setState(() => _error = null);
    try {
      await _detector.start();
      _detector.pitchStream.listen((result) {
        if (mounted) setState(() => _lastResult = result);
      });
      setState(() => _isListening = true);
    } catch (e) {
      setState(() => _error = 'Нет доступа к микрофону: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tuning = _tunings[_selectedTuning]!;
    final double centsOff = _lastResult?.centsOff ?? 0.0;
    final inTune = _lastResult != null && centsOff.abs() < 5;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Тюнер',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 160,
              width: 220,
              child: CustomPaint(
                painter: _GaugePainter(centsOff: centsOff, active: _lastResult != null),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Text(
                          _lastResult?.noteName ?? '–',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_lastResult != null)
                          Text(
                            '${_lastResult!.frequency.toStringAsFixed(1)} Hz',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error != null
                  ? _error!
                  : !_isListening
                      ? 'Нажми «Слушать», чтобы настроить струну'
                      : inTune
                          ? 'Струна настроена'
                          : centsOff < 0
                              ? 'Подтяни струну — звучит ниже'
                              : 'Ослабь струну — звучит выше',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _error != null
                    ? AppColors.error
                    : inTune
                        ? AppColors.primary
                        : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(tuning.length, (index) {
                final note = tuning[index];
                final isTarget = _lastResult?.noteName == note;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isTarget ? AppColors.primary : AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      note,
                      style: TextStyle(
                        color: isTarget ? Colors.black : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _toggleListening,
              icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded),
              label: Text(_isListening ? 'Остановить' : 'Слушать'),
            ),
            const SizedBox(height: 24),
            const Text('Строй гитары', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _tunings.keys.map((name) {
                return ChoiceChip(
                  label: Text(name),
                  selected: _selectedTuning == name,
                  onSelected: (_) => setState(() => _selectedTuning = name),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.centsOff, required this.active});

  final double centsOff;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    final track = Paint()
      ..color = AppColors.surfaceElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      track,
    );

    if (active) {
      final double clamped = centsOff.clamp(-50, 50) / 50;
      final double angle = pi + (clamped + 1) / 2 * pi;
      final indicator = Paint()
        ..color = centsOff.abs() < 5 ? AppColors.primary : AppColors.warning
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      final startAngle = angle - 0.06;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        0.12,
        false,
        indicator,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.centsOff != centsOff || oldDelegate.active != active;
}
