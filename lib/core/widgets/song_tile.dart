import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/song.dart';
import '../../data/services/favorites_store.dart';
import '../theme/app_colors.dart';

class SongTile extends StatelessWidget {
  const SongTile({super.key, required this.song, required this.onTap});

  final SongSummary song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesStore>();
    final isFavorite = favorites.isFavorite(song);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 46,
                height: 46,
                color: AppColors.surfaceElevated,
                child: song.imageUrl == null
                    ? const Icon(Icons.music_note_rounded, color: AppColors.primary)
                    : Image.network(
                        song.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.music_note_rounded,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => favorites.toggle(song),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
