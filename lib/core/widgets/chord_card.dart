import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/repositories/songs_repository.dart';
import '../theme/app_colors.dart';

/// Карточка с диаграммой аккорда (картинка грифа + название).
///
/// Диаграмма подтягивается напрямую с amdm.ru; если сеть недоступна или
/// именно такого файла там нет — используется собственная картинка из
/// ассетов, а если и её нет — просто иконка.
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
              child: SvgPicture.network(
                SongsRepository.chordDiagramUrl(name),
                fit: BoxFit.contain,
                placeholderBuilder: (_) => _AssetFallback(assetPath: _assetPath),
                errorBuilder: (_, __, ___) => _AssetFallback(assetPath: _assetPath),
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

class _AssetFallback extends StatelessWidget {
  const _AssetFallback({required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.music_note_rounded,
        color: AppColors.textSecondary,
      ),
    );
  }
}
