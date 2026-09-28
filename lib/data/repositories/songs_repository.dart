import '../models/artist.dart';
import '../models/song.dart';
import '../services/chords_api_service.dart';

/// Единая точка доступа к данным о песнях, исполнителях и подборках.
/// Экраны не знают, что за источник данных стоит за репозиторием.
class SongsRepository {
  SongsRepository({ChordsApiService? api}) : _api = api ?? ChordsApiService();

  final ChordsApiService _api;

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

  void dispose() => _api.dispose();
}
