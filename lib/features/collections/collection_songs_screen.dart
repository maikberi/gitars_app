import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/song_tile.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/song.dart';
import '../../data/repositories/songs_repository.dart';
import '../song_detail/song_detail_screen.dart';

/// Список песен по ссылке конкретного исполнителя или подборки.
class CollectionSongsScreen extends StatefulWidget {
  const CollectionSongsScreen({
    super.key,
    required this.title,
    required this.link,
    required this.repository,
  });

  final String title;
  final String link;
  final SongsRepository repository;

  @override
  State<CollectionSongsScreen> createState() => _CollectionSongsScreenState();
}

class _CollectionSongsScreenState extends State<CollectionSongsScreen> {
  late Future<List<SongSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchSongsFromLink(widget.link);
  }

  void _reload() {
    setState(() {
      _future = widget.repository.fetchSongsFromLink(widget.link);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<SongSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(height: 400);
          }
          if (snapshot.hasError) {
            return ErrorView(
              height: 400,
              message: 'Не удалось загрузить песни.\n${snapshot.error}',
              onRetry: _reload,
            );
          }
          final songs = snapshot.data ?? const [];
          if (songs.isEmpty) {
            return const EmptyView(message: 'Здесь пока нет песен', height: 400);
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongTile(
                song: song,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SongDetailScreen(
                      song: song,
                      repository: widget.repository,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
