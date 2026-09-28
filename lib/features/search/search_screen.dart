import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/chord_card.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/song_tile.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/song.dart';
import '../../data/repositories/songs_repository.dart';
import '../song_detail/song_detail_screen.dart';

enum _SearchScope { songs, artists, chords }

/// Единый экран поиска: песни (реальный поиск по amdm.ru), исполнители
/// (выводятся из тех же результатов) и аккорды (локальный список).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.repository});

  final SongsRepository repository;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  _SearchScope _scope = _SearchScope.songs;
  String _query = '';
  Future<List<SongSummary>>? _future;

  void _runSearch(String query) {
    setState(() {
      _query = query;
      _future = query.trim().isEmpty
          ? null
          : widget.repository.fetchSongsPage(page: 1, query: query.trim());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const Text(
                    'Поиск',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppSearchField(
                controller: _controller,
                autofocus: true,
                hintText: 'Поиск песен, исполнителей, аккордов...',
                onChanged: _runSearch,
                onSubmitted: _runSearch,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Песни'),
                    selected: _scope == _SearchScope.songs,
                    onSelected: (_) => setState(() => _scope = _SearchScope.songs),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Исполнители'),
                    selected: _scope == _SearchScope.artists,
                    onSelected: (_) => setState(() => _scope = _SearchScope.artists),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Аккорды'),
                    selected: _scope == _SearchScope.chords,
                    onSelected: (_) => setState(() => _scope = _SearchScope.chords),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_scope == _SearchScope.chords) {
      return _ChordResults(query: _query);
    }

    if (_query.trim().isEmpty) {
      return const EmptyView(message: 'Начни вводить запрос');
    }

    return FutureBuilder<List<SongSummary>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: 'Не удалось выполнить поиск.\n${snapshot.error}',
            onRetry: () => _runSearch(_query),
          );
        }
        final songs = snapshot.data ?? const [];
        if (songs.isEmpty) {
          return const EmptyView(message: 'Ничего не найдено');
        }

        if (_scope == _SearchScope.artists) {
          final byArtist = <String, SongSummary>{};
          for (final song in songs) {
            byArtist.putIfAbsent(song.artist, () => song);
          }
          final artists = byArtist.values.toList();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final song = artists[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.surfaceElevated,
                  backgroundImage:
                      song.imageUrl != null ? NetworkImage(song.imageUrl!) : null,
                  child: song.imageUrl == null
                      ? const Icon(Icons.person, color: AppColors.textSecondary)
                      : null,
                ),
                title: Text(song.artist,
                    style: const TextStyle(color: AppColors.textPrimary)),
                onTap: () => _runSearch(song.artist),
              );
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }
}

class _ChordResults extends StatelessWidget {
  const _ChordResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final filtered = SongsRepository.chordNames
        .where((c) => c.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (filtered.isEmpty) {
      return const EmptyView(message: 'Аккорд не найден');
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) => ChordCard(name: filtered[index]),
    );
  }
}
