import 'package:flutter/material.dart';

import '../../data/models/artist.dart';
import '../../data/models/song.dart';
import '../../data/repositories/songs_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/cors_proxy.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/state_views.dart';
import '../collections/collection_songs_screen.dart';
import '../search/search_screen.dart';
import '../song_detail/song_detail_screen.dart';
import '../songs/songs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final SongsRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<HomeSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = widget.repository.fetchHomeSnapshot();
  }

  void _reload() {
    setState(() {
      _snapshotFuture = widget.repository.fetchHomeSnapshot();
    });
  }

  void _openSong(SongSummary song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(
          song: song,
          repository: widget.repository,
        ),
      ),
    );
  }

  void _openArtist(Artist artist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CollectionSongsScreen(
          title: artist.name,
          link: artist.songsLink,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Гитара',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Песни. Аккорды. Тюнер. Всё для твоей игры.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(repository: widget.repository),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textSecondary),
                      SizedBox(width: 10),
                      Text(
                        'Поиск песен, исполнителей, аккордов...',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SongsScreen(repository: widget.repository),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.heroGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Начни играть сегодня',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Популярные песни, простые аккорды и всё,\nчто нужно для старта',
                              style: TextStyle(color: Colors.black87, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Популярное',
              actionLabel: 'Смотреть все',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongsScreen(repository: widget.repository),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<HomeSnapshot>(
              future: _snapshotFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView(height: 300);
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    height: 300,
                    message: 'Не удалось загрузить данные.\n${snapshot.error}',
                    onRetry: _reload,
                  );
                }
                final data = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 128,
                      child: data.songs.isEmpty
                          ? const EmptyView(message: 'Пока пусто', height: 128)
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: data.songs.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final song = data.songs[index];
                                return _PopularSongCard(
                                  song: song,
                                  onTap: () => _openSong(song),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Подборки', actionLabel: 'Смотреть все'),
                    SizedBox(
                      height: 110,
                      child: data.collections.isEmpty
                          ? const EmptyView(message: 'Пока пусто', height: 110)
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: data.collections.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final collection = data.collections[index];
                                return _CollectionCard(
                                  collection: collection,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CollectionSongsScreen(
                                        title: collection.title,
                                        link: collection.link,
                                        repository: widget.repository,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Популярные исполнители'),
                    SizedBox(
                      height: 110,
                      child: data.artists.isEmpty
                          ? const EmptyView(message: 'Пока пусто', height: 110)
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: data.artists.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 18),
                              itemBuilder: (context, index) {
                                final artist = data.artists[index];
                                return _ArtistAvatar(
                                  artist: artist,
                                  onTap: () => _openArtist(artist),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _PopularSongCard extends StatelessWidget {
  const _PopularSongCard({required this.song, required this.onTap});
  final SongSummary song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 96,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Container(
                width: 72,
                height: 72,
                color: AppColors.surfaceElevated,
                child: song.imageUrl == null
                    ? const Icon(Icons.album_rounded, color: AppColors.primary)
                    : Image.network(
                        withCorsProxyIfWeb(song.imageUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.album_rounded, color: AppColors.primary),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection, required this.onTap});
  final SongCollection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          image: collection.imageUrl == null
              ? null
              : DecorationImage(
                  image: NetworkImage(withCorsProxyIfWeb(collection.imageUrl!)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                ),
        ),
        padding: const EdgeInsets.all(12),
        alignment: Alignment.bottomLeft,
        child: Text(
          collection.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ArtistAvatar extends StatelessWidget {
  const _ArtistAvatar({required this.artist, required this.onTap});
  final Artist artist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.surfaceElevated,
              backgroundImage: artist.imageUrl != null
                  ? NetworkImage(withCorsProxyIfWeb(artist.imageUrl!))
                  : null,
              child: artist.imageUrl == null
                  ? const Icon(Icons.person, color: AppColors.textSecondary)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              artist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
