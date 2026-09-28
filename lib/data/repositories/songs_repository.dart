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

/// Каталог для просмотра/поиска, собранный на сервере при сборке веб-версии
/// (см. tool/build_catalog.dart) — названия, ссылки и обложки, без текста
/// песен. Загружается один раз и живёт в памяти на время сессии.
class _WebCatalog {
  _WebCatalog({
    required this.artists,
    required this.collections,
    required this.songs,
    required this.bySourceLink,
  });

  final List<Artist> artists;
  final List<SongCollection> collections;
  final List<SongSummary> songs;
  final Map<String, List<String>> bySourceLink;
}

/// Единая точка доступа к данным о песнях, исполнителях и подборках.
/// Экраны не знают, что за источник данных стоит за репозиторием.
class SongsRepository {
  SongsRepository({ChordsApiService? api, http.Client? httpClient})
      : _api = api ?? ChordsApiService(),
        _httpClient = httpClient ?? http.Client();

  final ChordsApiService _api;
  final http.Client _httpClient;

  Future<_WebCatalog?>? _catalogFuture;

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

  /// Каталог `data/catalog.json` — статический файл на том же домене, что
  /// и само приложение (собран GitHub Actions прямо с amdm.ru на сервере,
  /// см. tool/build_catalog.dart), поэтому грузится без CORS и без прокси.
  /// Запрашивается один раз за сессию и переиспользуется. Возвращает null,
  /// если файла нет (например, локальный `flutter run -d chrome`) — тогда
  /// вызывающий код идёт в живой запрос через ChordsApiService.
  Future<_WebCatalog?> _loadCatalog() {
    if (!kIsWeb) return Future.value(null);
    return _catalogFuture ??= _fetchCatalog();
  }

  Future<_WebCatalog?> _fetchCatalog() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('data/catalog.json'))
          .timeout(const Duration(seconds: 8));
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
      final bySourceLink = (json['bySourceLink'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as List).cast<String>()),
      );

      if (artists.isEmpty && collections.isEmpty && songs.isEmpty) return null;
      return _WebCatalog(
        artists: artists,
        collections: collections,
        songs: songs,
        bySourceLink: bySourceLink,
      );
    } catch (_) {
      return null;
    }
  }

  /// Данные для Главного экрана.
  Future<HomeSnapshot> fetchHomeSnapshot() async {
    final catalog = await _loadCatalog();
    if (catalog != null) {
      final popularIds = catalog.bySourceLink['popular'] ?? const [];
      final byId = {for (final s in catalog.songs) s.id: s};
      final popular = popularIds.map((id) => byId[id]).whereType<SongSummary>().toList();
      return HomeSnapshot(
        artists: catalog.artists,
        collections: catalog.collections,
        songs: popular,
      );
    }

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

  Future<List<Artist>> fetchPopularArtists() async {
    final catalog = await _loadCatalog();
    if (catalog != null) return catalog.artists;
    return _api.fetchPopularArtists();
  }

  Future<List<SongCollection>> fetchThemeCollections() async {
    final catalog = await _loadCatalog();
    if (catalog != null) return catalog.collections;
    return _api.fetchThemeCollections();
  }

  /// Список песен: без [query] — общий каталог (на вебе — все песни из
  /// собранного каталога, единой страницей); с [query] — поиск по
  /// названию/исполнителю внутри каталога на вебе, либо живой поиск через
  /// amdm.ru на остальных платформах.
  Future<List<SongSummary>> fetchSongsPage({required int page, String? query}) async {
    final catalog = await _loadCatalog();
    if (catalog != null) {
      if (page > 1) return const [];
      if (query == null || query.trim().isEmpty) return catalog.songs;
      final needle = query.trim().toLowerCase();
      return catalog.songs
          .where((s) =>
              s.title.toLowerCase().contains(needle) ||
              s.artist.toLowerCase().contains(needle))
          .toList();
    }
    return _api.fetchSongsPage(page: page, query: query);
  }

  Future<List<SongSummary>> fetchSongsFromLink(String link) async {
    final catalog = await _loadCatalog();
    if (catalog != null) {
      final ids = catalog.bySourceLink[link];
      if (ids != null) {
        final byId = {for (final s in catalog.songs) s.id: s};
        return ids.map((id) => byId[id]).whereType<SongSummary>().toList();
      }
    }
    return _api.fetchSongsFromLink(link);
  }

  /// Текст и аккорды конкретной песни всегда запрашиваются вживую — в
  /// статический каталог они намеренно не попадают (см. комментарий в
  /// tool/build_catalog.dart).
  Future<SongDetails> fetchSongDetails(SongSummary song) {
    return _api.fetchSongDetails(song);
  }

  void dispose() {
    _api.dispose();
    _httpClient.close();
  }
}
