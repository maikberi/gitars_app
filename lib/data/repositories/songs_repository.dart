import '../models/artist.dart';
import '../models/song.dart';
import '../services/chords_api_service.dart';

/// Единая точка доступа к данным о песнях, исполнителях и подборках.
/// Экраны не знают, что за источник данных стоит за репозиторием.
class SongsRepository {
  SongsRepository({ChordsApiService? api}) : _api = api ?? ChordsApiService();

  final ChordsApiService _api;

  static const List<Artist> popularArtists = [
    Artist(
      name: 'Кино',
      description: 'Виктор Цой — легенда русского рока',
      image: 'lib/images/coi2.png',
      songsLink: 'https://3akkorda.net/russkie/viktor-coj/',
    ),
    Artist(
      name: 'ДДТ',
      description: 'Юрий Шевчук и группа ДДТ',
      image: 'lib/images/nervi.png',
      songsLink: 'https://3akkorda.net/russkie/ddt/',
    ),
    Artist(
      name: 'Сплин',
      description: 'Александр Васильев и «Сплин»',
      image: 'lib/images/bi22.png',
      songsLink: 'https://3akkorda.net/russkie/splin/',
    ),
    Artist(
      name: 'Король и Шут',
      description: 'Хоррор-панк из Санкт-Петербурга',
      image: 'lib/images/king.png',
      songsLink: 'https://3akkorda.net/russkie/korol-i-shut/',
    ),
    Artist(
      name: 'Ария',
      description: 'Легенда советского и российского метала',
      image: 'lib/images/aria.png',
      songsLink: 'https://3akkorda.net/russkie/ariya/',
    ),
    Artist(
      name: 'Макс Корж',
      description: 'Автор-исполнитель из Беларуси',
      image: 'lib/images/max.png',
      songsLink: 'https://3akkorda.net/russkie/maks-korzh/',
    ),
    Artist(
      name: 'Алёна Швец',
      description: 'Певица, автор-исполнитель, гитаристка',
      image: 'lib/images/shvec.png',
      songsLink: 'https://3akkorda.net/russkie/alena-svec/',
    ),
    Artist(
      name: 'Nautilus Pompilius',
      description: 'Уральско-питерская рок-группа',
      image: 'lib/images/nautilius.png',
      songsLink: 'https://3akkorda.net/russkie/nautilus-pompilius/',
    ),
  ];

  static const List<SongCollection> collections = [
    SongCollection(
      title: 'Для новичка',
      subtitle: 'Простые песни на 3 аккордах',
      image: 'lib/images/gitara7.png',
      link: 'https://amdm.ru/akkordi/popular/all/',
    ),
    SongCollection(
      title: 'Русский рок',
      subtitle: 'Кино, ДДТ, Сплин и другие',
      image: 'lib/images/gitara2.png',
      link: 'https://amdm.ru/akkordi/',
    ),
    SongCollection(
      title: 'Песни из фильмов',
      subtitle: 'Саундтреки и легендарные хиты',
      image: 'lib/images/pfilm.png',
      link: 'https://amdm.ru/akkordi/prikolnie_pesni/',
    ),
    SongCollection(
      title: 'У костра',
      subtitle: 'Атмосфера похода и гитары у огня',
      image: 'lib/images/pcoster2.png',
      link: 'https://amdm.ru/akkordi/popular/all/',
    ),
    SongCollection(
      title: 'Народные и застольные',
      subtitle: 'Песни для большой компании',
      image: 'lib/images/pstol2.png',
      link: 'https://amdm.ru/akkordi/popular/all/',
    ),
    SongCollection(
      title: 'Дворовые',
      subtitle: 'Классика под гитару во дворе',
      image: 'lib/images/pdvor.png',
      link: 'https://amdm.ru/akkordi/popular/all/',
    ),
  ];

  static const List<String> chordNames = [
    'A', 'A7', 'Am', 'B', 'B7', 'Bm',
    'C', 'C7', 'Cm', 'D', 'D7', 'Dm',
    'E', 'E7', 'Em', 'F', 'F7', 'Fm',
    'G', 'Gm',
  ];

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
