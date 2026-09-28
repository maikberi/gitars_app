import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/song_tile.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/song.dart';
import '../../data/repositories/songs_repository.dart';
import '../../data/services/favorites_store.dart';
import '../song_detail/song_detail_screen.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key, required this.repository});

  final SongsRepository repository;

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  final _searchController = TextEditingController();
  int _page = 1;
  String? _query;
  bool _favoritesOnly = false;
  late Future<List<SongSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchSongsPage(page: _page);
  }

  void _reload() {
    setState(() {
      _future = widget.repository.fetchSongsPage(page: _page, query: _query);
    });
  }

  void _openSong(SongSummary song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(song: song, repository: widget.repository),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesStore>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Песни',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppSearchField(
              controller: _searchController,
              hintText: 'Поиск песен...',
              onSubmitted: (value) {
                _query = value.trim().isEmpty ? null : value.trim();
                _page = 1;
                _reload();
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Все'),
                  selected: !_favoritesOnly,
                  onSelected: (_) => setState(() => _favoritesOnly = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Избранное'),
                  selected: _favoritesOnly,
                  onSelected: (_) => setState(() => _favoritesOnly = true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _favoritesOnly
                ? _FavoritesList(
                    favorites: favorites.all,
                    onTap: _openSong,
                  )
                : FutureBuilder<List<SongSummary>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingView();
                      }
                      if (snapshot.hasError) {
                        return ErrorView(
                          message: 'Не удалось загрузить песни.\n${snapshot.error}',
                          onRetry: _reload,
                        );
                      }
                      final songs = snapshot.data ?? const [];
                      if (songs.isEmpty) {
                        return const EmptyView(message: 'Ничего не найдено');
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: songs.length + 1,
                        itemBuilder: (context, index) {
                          if (index == songs.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: _page > 1
                                        ? () {
                                            _page--;
                                            _reload();
                                          }
                                        : null,
                                    icon: const Icon(Icons.arrow_back_ios,
                                        color: AppColors.primary, size: 18),
                                  ),
                                  Text('$_page',
                                      style: const TextStyle(color: AppColors.textSecondary)),
                                  IconButton(
                                    onPressed: () {
                                      _page++;
                                      _reload();
                                    },
                                    icon: const Icon(Icons.arrow_forward_ios,
                                        color: AppColors.primary, size: 18),
                                  ),
                                ],
                              ),
                            );
                          }
                          final song = songs[index];
                          return SongTile(song: song, onTap: () => _openSong(song));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.favorites, required this.onTap});

  final List<SongSummary> favorites;
  final ValueChanged<SongSummary> onTap;

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const EmptyView(message: 'Пока нет избранных песен');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final song = favorites[index];
        return SongTile(song: song, onTap: () => onTap(song));
      },
    );
  }
}
