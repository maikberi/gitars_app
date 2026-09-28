import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';

/// Хранит избранные песни пользователя между запусками приложения
/// и уведомляет UI об изменениях.
class FavoritesStore extends ChangeNotifier {
  static const _prefsKey = 'favorite_songs_v1';

  final Map<String, SongSummary> _favorites = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<SongSummary> get all => _favorites.values.toList(growable: false);
  int get count => _favorites.length;

  bool isFavorite(SongSummary song) => _favorites.containsKey(song.id);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? const [];
    for (final entry in raw) {
      try {
        final song = SongSummary.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        );
        _favorites[song.id] = song;
      } catch (_) {
        // пропускаем повреждённую запись
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(SongSummary song) async {
    if (_favorites.containsKey(song.id)) {
      _favorites.remove(song.id);
    } else {
      _favorites[song.id] = song;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _favorites.values.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }
}
