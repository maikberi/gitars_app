import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/chord_card.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/song.dart';
import '../../data/repositories/songs_repository.dart';
import '../../data/services/favorites_store.dart';
import 'chord_transposer.dart';

class SongDetailScreen extends StatefulWidget {
  const SongDetailScreen({
    super.key,
    required this.song,
    required this.repository,
  });

  final SongSummary song;
  final SongsRepository repository;

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late Future<SongDetails> _future;
  final _scrollController = ScrollController();
  int _semitones = 0;
  bool _autoScroll = false;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchSongDetails(widget.song);
  }

  void _reload() {
    setState(() {
      _future = widget.repository.fetchSongDetails(widget.song);
    });
  }

  void _toggleAutoScroll(bool value) {
    setState(() => _autoScroll = value);
    _autoScrollTimer?.cancel();
    if (value) {
      _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
        if (!_scrollController.hasClients) return;
        final next = _scrollController.offset + 1;
        if (next >= _scrollController.position.maxScrollExtent) {
          _autoScrollTimer?.cancel();
          setState(() => _autoScroll = false);
          return;
        }
        _scrollController.jumpTo(next);
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesStore>();
    final isFavorite = favorites.isFavorite(widget.song);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.song.title, style: const TextStyle(fontSize: 17)),
            Text(
              widget.song.artist,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => favorites.toggle(widget.song),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: FutureBuilder<SongDetails>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(height: 500);
          }
          if (snapshot.hasError) {
            return ErrorView(
              height: 500,
              message: 'Не удалось загрузить песню.\n${snapshot.error}',
              onRetry: _reload,
            );
          }
          final details = snapshot.data!;
          return Column(
            children: [
              if (details.chordsUsed.isNotEmpty)
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: details.chordsUsed.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final chord = ChordTransposer.transposeLine(
                        details.chordsUsed[index],
                        _semitones,
                      );
                      return SizedBox(width: 72, child: ChordCard(name: chord));
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text('Тональность', style: TextStyle(color: AppColors.textSecondary)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _semitones--),
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                    ),
                    Text('${_semitones >= 0 ? '+' : ''}$_semitones',
                        style: const TextStyle(color: AppColors.textPrimary)),
                    IconButton(
                      onPressed: () => setState(() => _semitones++),
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    const Text('Автопрокрутка', style: TextStyle(color: AppColors.textSecondary)),
                    Switch(
                      value: _autoScroll,
                      activeColor: AppColors.primary,
                      onChanged: _toggleAutoScroll,
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: details.lines.map((line) {
                      final text = line.isChordLine
                          ? ChordTransposer.transposeLine(line.text, _semitones)
                          : line.text;
                      return Text(
                        text.isEmpty ? ' ' : text,
                        style: TextStyle(
                          color: line.isChordLine ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: line.isChordLine ? FontWeight.w700 : FontWeight.w400,
                          fontFamily: 'monospace',
                          fontSize: 15,
                          height: 1.5,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
