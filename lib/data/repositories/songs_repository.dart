import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/artist.dart';
import '../models/song.dart';
import '../services/chords_api_service.dart';

/// Данные для трёх горизонтальных секций Главного экрана за один заход.
class HomeSnapshot {
  const HomeSnapshot({
    required this.artists,
    required this.collections,
    required this.songs,
  });

  final List<Artist> artists;
  final List<SongCollection> collections;
  final List<SongSummary> songs;
}

/// Единая точка доступа к данным о песнях, исполнителях и подборках.
/// Экраны не знают, что за источник данных стоит за репозиторием.
class SongsRepository {
  SongsRepository({ChordsApiService? api, http.Client? httpClient})
      : _api = api ?? ChordsApiService(),
        _httpClient = httpClient ?? http.Client();

  final ChordsApiService _api;
  final http.Client _httpClient;

  /// Названия базовых аккордов для раздела «Аккорды». На amdm.ru нет
  /// страницы-каталога «вот эти N базовых аккордов», только генератор
  /// произвольного аккорда — поэтому сам список имён статичный, а вот
  /// картинки грифов под каждое имя подтягиваются с сайта (см.
  /// [chordDiagramUrl]).
  static const List<String> chordNames = [
    'A', 'A7', 'Am', 'B', 'B7', 'Bm',
    'C', 'C7', 'Cm', 'D', 'D7', 'Dm',
    'E', 'E7', 'Em', 'F', 'F7', 'Fm',
    'G', 'Gm',
  ];

  /// URL SVG-диаграммы аккорда на amdm.ru. Судя по реальным ссылкам с их
  /// страницы песни, `#` в имени аккорда заменяется на `w`
  /// (например `C#m7` → `Cwm7_0.svg`); для обычных аккордов без диезов
  /// (как в [chordNames]) имя используется как есть.
  static String chordDiagramUrl(String chordName) {
    final slug = chordName.replaceAll('#', 'w');
    return 'https://amdm.ru/cs/images/chords/svg/${slug}_0.svg';
  }

  /// Данные для Главного экрана. На вебе сначала пробуем `data/home.json` —
  /// статический файл, который GitHub Actions выкачивает с amdm.ru прямо
  /// на сервере при каждой сборке (см. tool/fetch_home_data.dart) и кладёт
  /// в саму сборку. Он лежит на том же домене, что и приложение, поэтому
  /// грузится без всякого CORS и без прокси. Если файла нет (например, при
  /// локальном `flutter run -d chrome`) или он не загрузился — идём в живой
  /// запрос через ChordsApiService, как на остальных платформах.
  Future<HomeSnapshot> fetchHomeSnapshot() async {
    final snapshot = kIsWeb ? await _tryLoadStaticSnapshot() : null;
    if (snapshot != null) return snapshot;

    final results = await Future.wait([
      fetchPopularArtists(),
      fetchThemeCollections(),
      fetchSongsPage(page: 1),
    ]);
    return HomeSnapshot(
      artists: results[0] as List<Artist>,
      collections: results[1] as List<SongCollection>,
      songs: results[2] as List<SongSummary>,
    );
  }

  Future<HomeSnapshot?> _tryLoadStaticSnapshot() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('data/home.json'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final artists = (json['artists'] as List).map((raw) {
        final map = raw as Map<String, dynamic>;
        return Artist(
          name: map['name'] as String,
          songsLink: map['songsLink'] as String,
          imageUrl: map['imageUrl'] as String?,
        );
      }).toList();
      final collections = (json['collections'] as List).map((raw) {
        final map = raw as Map<String, dynamic>;
        return SongCollection(
          title: map['title'] as String,
          link: map['link'] as String,
          imageUrl: map['imageUrl'] as String?,
        );
      }).toList();
      final songs = (json['songs'] as List)
          .map((raw) => SongSummary.fromJson(raw as Map<String, dynamic>))
          .toList();

      if (artists.isEmpty && collections.isEmpty && songs.isEmpty) return null;
      return HomeSnapshot(artists: artists, collections: collections, songs: songs);
    } catch (_) {
      return null;
    }
  }

  Future<List<Artist>> fetchPopularArtists() => _api.fetchPopularArtists();

  Future<List<SongCollection>> fetchThemeCollections() => _api.fetchThemeCollections();

  Future<List<SongSummary>> fetchSongsPage({required int page, String? query}) {
    return _api.fetchSongsPage(page: page, query: query);
  }

  Future<List<SongSummary>> fetchSongsFromLink(String link) {
    return _api.fetchSongsFromLink(link);
  }

  Future<SongDetails> fetchSongDetails(SongSummary song) {
    return _api.fetchSongDetails(song);
  }

  void dispose() {
    _api.dispose();
    _httpClient.close();
  }
}
