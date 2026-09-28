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
  final _scrollController = ScrollController();
  final List<SongSummary> _songs = [];

  int _page = 0;
  String? _query;
  bool _favoritesOnly = false;
  bool _isLoading = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoading || _error != null) return;
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 400;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore({bool reset = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
      if (reset) {
        _songs.clear();
        _page = 0;
        _hasMore = true;
      }
    });

    final nextPage = _page + 1;
    try {
      final results = await widget.repository.fetchSongsPage(page: nextPage, query: _query);
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _songs.addAll(results);
        _hasMore = results.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _query = value.trim().isEmpty ? null : value.trim();
    _loadMore(reset: true);
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
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesStore>();

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
              onSubmitted: _onSearchChanged,
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
                ? _FavoritesList(favorites: favorites.all, onTap: _openSong)
                : _buildSongsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList() {
    if (_songs.isEmpty && _isLoading) {
      return const LoadingView();
    }
    if (_songs.isEmpty && _error != null) {
      return ErrorView(
        message: 'Не удалось загрузить песни.\n$_error',
        onRetry: () => _loadMore(reset: true),
      );
    }
    if (_songs.isEmpty) {
      return const EmptyView(message: 'Ничего не найдено');
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _songs.length + 1,
      itemBuilder: (context, index) {
        if (index == _songs.length) {
          if (_error != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: TextButton(
                  onPressed: _loadMore,
                  child: const Text('Не удалось загрузить ещё — повторить',
                      style: TextStyle(color: AppColors.primary)),
                ),
              ),
            );
          }
          if (_isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          return const SizedBox(height: 24);
        }
        final song = _songs[index];
        return SongTile(song: song, onTap: () => _openSong(song));
      },
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
