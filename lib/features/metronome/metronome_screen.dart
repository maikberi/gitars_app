import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

class MetronomeScreen extends StatefulWidget {
  const MetronomeScreen({super.key});

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  int _bpm = 120;
  int _beatsPerBar = 4;
  int _currentBeat = 0;
  bool _isPlaying = false;
  Timer? _timer;

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    _timer?.cancel();
    if (_isPlaying) {
      _currentBeat = 0;
      _tick();
      _timer = Timer.periodic(
        Duration(milliseconds: (60000 / _bpm).round()),
        (_) => _tick(),
      );
    }
  }

  void _tick() {
    SystemSound.play(SystemSoundType.click);
    setState(() => _currentBeat = (_currentBeat + 1) % _beatsPerBar);
  }

  void _changeBpm(int delta) {
    setState(() => _bpm = (_bpm + delta).clamp(30, 240).toInt());
    if (_isPlaying) _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: (60000 / _bpm).round()),
      (_) => _tick(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Метроном',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '$_bpm',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 64,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text('BPM', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundIconButton(icon: Icons.remove, onTap: () => _changeBpm(-1)),
                const SizedBox(width: 24),
                _BeatDots(count: _beatsPerBar, current: _currentBeat, active: _isPlaying),
                const SizedBox(width: 24),
                _RoundIconButton(icon: Icons.add, onTap: () => _changeBpm(1)),
              ],
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              children: [1, 2, 3, 4].map((value) {
                final label = value == 1 ? '1/4' : value == 2 ? '2/4' : value == 3 ? '3/4' : '4/4';
                return ChoiceChip(
                  label: Text(label),
                  selected: _beatsPerBar == value,
                  onSelected: (_) => setState(() {
                    _beatsPerBar = value;
                    _currentBeat = 0;
                  }),
                );
              }).toList(),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}

class _BeatDots extends StatelessWidget {
  const _BeatDots({required this.count, required this.current, required this.active});
  final int count;
  final int current;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        final isCurrent = active && index == current;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent ? AppColors.primary : AppColors.surfaceElevated,
          ),
        );
      }),
    );
  }
}
