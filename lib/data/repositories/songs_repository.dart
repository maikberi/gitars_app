import '../models/artist.dart';
import '../models/song.dart';
import '../services/chords_api_service.dart';

/// Единая точка доступа к данным о песнях, исполнителях и подборках.
/// Экраны не знают, что за источник данных стоит за репозиторием.
class SongsRepository {
  SongsRepository({ChordsApiService? api}) : _api = api ?? ChordsApiService();

  final ChordsApiService _api;

  // Ссылки ниже — реальные адреса со страниц amdm.ru (проверено по присланной
  // разметке), а не догадки: /akkordi/<slug>/ у них общий шаблон и для
  // исполнителей, и для тематических подборок.
  static const List<Artist> popularArtists = [
    Artist(
      name: 'Король и Шут',
      description: 'Хоррор-панк из Санкт-Петербурга',
      image: 'lib/images/king.png',
      songsLink: 'https://amdm.ru/akkordi/korol_i_shut/',
    ),
    Artist(
      name: 'Гражданская Оборона',
      description: 'ГО, ГрОб — Егор Летов',
      image: 'lib/images/nervi.png',
      songsLink: 'https://amdm.ru/akkordi/grazhdanskaya_oborona/',
    ),
    Artist(
      name: 'Сектор Газа',
      description: 'Юрий Хой и «Сектор Газа»',
      image: 'lib/images/gitara.png',
      songsLink: 'https://amdm.ru/akkordi/sektor_gaza/',
    ),
    Artist(
      name: 'ДДТ',
      description: 'Юрий Шевчук и группа ДДТ',
      image: 'lib/images/nervi.png',
      songsLink: 'https://amdm.ru/akkordi/ddt/',
    ),
    Artist(
      name: 'Сплин',
      description: 'Александр Васильев и «Сплин»',
      image: 'lib/images/bi22.png',
      songsLink: 'https://amdm.ru/akkordi/splin/',
    ),
  ];

  static const List<SongCollection> collections = [
    SongCollection(
      title: 'Дворовые песни',
      subtitle: 'Классика под гитару во дворе',
      image: 'lib/images/pdvor.png',
      link: 'https://amdm.ru/akkordi/dvorovye_pesni/',
    ),
    SongCollection(
      title: 'Народные и застольные',
      subtitle: 'Песни для большой компании',
      image: 'lib/images/pstol2.png',
      link: 'https://amdm.ru/akkordi/narodnye_i_zastolnye_pesni/',
    ),
    SongCollection(
      title: 'Песни из кино и мультфильмов',
      subtitle: 'Саундтреки и легендарные хиты',
      image: 'lib/images/pfilm.png',
      link: 'https://amdm.ru/akkordi/pesni_iz_kino_i_multfilmov/',
    ),
    SongCollection(
      title: 'Туристические песни',
      subtitle: 'В поход с гитарой',
      image: 'lib/images/pcoster2.png',
      link: 'https://amdm.ru/akkordi/turisticheskie_pesni/',
    ),
    SongCollection(
      title: 'Прикольные песни',
      subtitle: 'Для весёлой компании',
      image: 'lib/images/gitara7.png',
      link: 'https://amdm.ru/akkordi/prikolnye_pesni/',
    ),
    SongCollection(
      title: 'Студенческие песни',
      subtitle: 'Студенческий фольклор',
      image: 'lib/images/gitara2.png',
      link: 'https://amdm.ru/akkordi/studencheskie_pesni/',
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
