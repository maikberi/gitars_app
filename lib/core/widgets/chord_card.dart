import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Карточка с диаграммой аккорда (картинка грифа + название).
class ChordCard extends StatelessWidget {
  const ChordCard({super.key, required this.name, this.onTap});

  final String name;
  final VoidCallback? onTap;

  String get _assetPath => 'lib/acords/$name.png';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                _assetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.music_note_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
