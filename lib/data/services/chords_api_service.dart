import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../models/artist.dart';
import '../models/song.dart';

/// Бросается, когда источник данных недоступен или прислал неожиданный ответ.
class ChordsApiException implements Exception {
  ChordsApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Слой доступа к данным о песнях/аккордах.
///
/// Публичного API для русскоязычных аккордов не существует, поэтому данные
/// берутся с открытых страниц источника и превращаются в типизированные
/// модели. Вся хрупкая работа с HTML-разметкой изолирована здесь — если
/// разметка сайта поменяется, поправить нужно только этот файл.
class ChordsApiService {
  ChordsApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://amdm.ru';
  static const _timeout = Duration(seconds: 12);

  /// В браузере (Flutter Web) прямой запрос к amdm.ru с чужого домена
  /// блокируется политикой CORS — amdm.ru не присылает заголовок
  /// `Access-Control-Allow-Origin`. На Android/iOS/desktop этого
  /// ограничения нет, там ходим напрямую; в вебе перебираем несколько
  /// публичных CORS-прокси по очереди — бесплатные сервисы такого рода
  /// сами по себе нестабильны, поэтому нельзя полагаться на один.
  static const List<String Function(String)> _corsProxies = [
    _viaAllOrigins,
    _viaCorsProxyIo,
    _viaCodeTabs,
  ];

  static String _viaAllOrigins(String url) =>
      'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';

  static String _viaCorsProxyIo(String url) =>
      'https://corsproxy.io/?url=${Uri.encodeComponent(url)}';

  static String _viaCodeTabs(String url) =>
      'https://api.codetabs.com/v1/proxy?quest=${Uri.encodeComponent(url)}';

  Future<Document> _getDocument(Uri uri) async {
    if (!kIsWeb) {
      final response = await _requestOrThrow(uri);
      return html_parser.parse(response.body);
    }

    Object? lastError;
    for (final proxy in _corsProxies) {
      final proxied = Uri.parse(proxy(uri.toString()));
      try {
        final response = await _requestOrThrow(proxied);
        return html_parser.parse(response.body);
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError is ChordsApiException
        ? lastError
        : ChordsApiException('Не удалось подключиться к серверу');
  }

  Future<http.Response> _requestOrThrow(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } catch (_) {
      throw ChordsApiException('Не удалось подключиться к серверу');
    }
    if (response.statusCode != 200) {
      throw ChordsApiException('Сервер вернул ошибку ${response.statusCode}');
    }
    return response;
  }

  /// Поиск песен по слову [query]. Пагинация ([page]) на amdm.ru для
  /// результатов поиска не подтверждена, поэтому пока всегда отдаётся
  /// первая страница результатов.
  Future<List<SongSummary>> fetchSongsPage({
    required int page,
    String? query,
  }) async {
    final uri = (query == null || query.isEmpty)
        ? Uri.parse('$_baseUrl/akkordi/popular/')
        : Uri.parse('$_baseUrl/search/?q=${Uri.encodeQueryComponent(query)}');
    final doc = await _getDocument(uri);
    return _parseSongRows(doc);
  }

  /// Список песен по произвольной ссылке исполнителя/подборки/темы —
  /// на amdm.ru все они используют одну и ту же вёрстку списка.
  Future<List<SongSummary>> fetchSongsFromLink(String link) async {
    final doc = await _getDocument(Uri.parse(link));
    return _parseSongRows(doc);
  }

  /// Блок «Популярные исполнители» на главной странице amdm.ru.
  Future<List<Artist>> fetchPopularArtists() async {
    final doc = await _getDocument(Uri.parse(_baseUrl));
    final section = _findWidgetByHeading(doc, 'Популярные исполнители');
    if (section == null) return const [];

    final result = <Artist>[];
    for (final cell in section.querySelectorAll('td.artist_name')) {
      final links = cell.querySelectorAll('a.artist');
      // Строка-песня (артист + трек) — не то, что нам нужно здесь.
      if (links.length != 1) continue;
      final name = links.first.text.trim();
      final href = links.first.attributes['href'];
      if (href == null || name.isEmpty) continue;

      final imageSrc = cell.parent?.querySelector('td.photo img')?.attributes['src'];
      final imageUrl =
          imageSrc == null ? null : Uri.parse(_baseUrl).resolve(imageSrc).toString();

      result.add(Artist(name: name, songsLink: href, imageUrl: imageUrl));
    }
    return result;
  }

  /// Блок «Аккорды песен по тематике» на главной странице amdm.ru.
  Future<List<SongCollection>> fetchThemeCollections() async {
    final doc = await _getDocument(Uri.parse(_baseUrl));
    final result = <SongCollection>[];
    for (final item in doc.querySelectorAll('.b-artist-tematika__item')) {
      final link = item.querySelector('a');
      final href = link?.attributes['href'];
      final title = link?.text.trim();
      if (href == null || title == null || title.isEmpty) continue;

      final imageSrc = item.querySelector('img')?.attributes['src'];
      final imageUrl =
          imageSrc == null ? null : Uri.parse(_baseUrl).resolve(imageSrc).toString();

      result.add(SongCollection(title: title, link: href, imageUrl: imageUrl));
    }
    return result;
  }

  /// Находит виджет `.b-index-top-songs__item` на главной странице по тексту
  /// его заголовка `<h3>` — так на ней размечены все три колонки
  /// («Новые подборы», «Популярные исполнители», «Популярные подборы»).
  Element? _findWidgetByHeading(Document doc, String heading) {
    for (final widget in doc.querySelectorAll('.b-index-top-songs__item')) {
      final h3 = widget.querySelector('h3')?.text.trim();
      if (h3 == heading) return widget;
    }
    return null;
  }

  /// amdm.ru использует два разных шаблона таблицы `table.items`:
  /// на общих страницах (главная, поиск, темы) каждая ячейка `td.artist_name`
  /// содержит две ссылки `a.artist` — исполнитель и песня; на странице
  /// конкретного исполнителя каждая песня — это просто `<a class="g-link">`
  /// без имени исполнителя в строке (оно и так известно по контексту).
  List<SongSummary> _parseSongRows(Document doc) {
    final byCell = _parseArtistSongCells(doc);
    if (byCell.isNotEmpty) return byCell;
    return _parseSingleArtistRows(doc);
  }

  List<SongSummary> _parseArtistSongCells(Document doc) {
    final cells = doc.querySelectorAll('td.artist_name');
    final result = <SongSummary>[];
    for (final cell in cells) {
      final item = _trySongFromCell(cell);
      if (item != null) result.add(item);
    }
    return result;
  }

  SongSummary? _trySongFromCell(Element cell) {
    try {
      final links = cell.querySelectorAll('a.artist');
      if (links.length < 2) return null;
      final artist = links[0].text.trim();
      final songLink = links[1];
      final title = songLink.text.trim();
      final href = songLink.attributes['href'];
      if (href == null || artist.isEmpty || title.isEmpty) return null;

      final imageSrc = cell.parent?.querySelector('td.photo img')?.attributes['src'];
      final imageUrl = imageSrc == null ? null : Uri.parse(_baseUrl).resolve(imageSrc).toString();

      return SongSummary.fromLink(
        title: title,
        artist: artist,
        link: href,
        imageUrl: imageUrl,
      );
    } catch (_) {
      return null;
    }
  }

  List<SongSummary> _parseSingleArtistRows(Document doc) {
    final artist = _impliedArtistName(doc);
    if (artist == null) return const [];

    final result = <SongSummary>[];
    for (final table in doc.querySelectorAll('table.items')) {
      for (final link in table.querySelectorAll('td > a.g-link')) {
        final title = link.text.trim();
        final href = link.attributes['href'];
        if (href == null || title.isEmpty) continue;
        result.add(SongSummary.fromLink(title: title, artist: artist, link: href));
      }
    }
    return result;
  }

  /// На amdm.ru заголовок страницы исполнителя/песни начинается с его имени
  /// вида "Исполнитель - ...", это самый надёжный источник имени без
  /// привязки к конкретной вёрстке блока.
  String? _impliedArtistName(Document doc) {
    final title = doc.querySelector('title')?.text;
    if (title == null) return null;
    final parts = title.split(' - ');
    if (parts.length < 2) return null;
    final artist = parts.first.trim();
    return artist.isEmpty ? null : artist;
  }

  /// Полный текст с аккордами для конкретной песни.
  ///
  /// На amdm.ru весь текст+аккорды лежат в одном `<pre class="podbor__text">`
  /// как уже готовый многострочный текст: аккорды — это
  /// `<div class="podbor__chord"><span>ИмяАккорда</span></div>` внутри строки,
  /// разделы песни — `<div class="podbor__keyword">[Куплет]:</div>`, а блок
  /// повторяющегося куплета обёрнут в `<div class="podbor__pripev">`.
  /// Разрывы строк там настоящие (`\n`), поэтому после снятия тегов текст
  /// остаётся построчным, как и раньше.
  Future<SongDetails> fetchSongDetails(SongSummary song) async {
    final doc = await _getDocument(Uri.parse(song.link));
    final container = doc.querySelector('pre.podbor__text');
    if (container == null) {
      throw ChordsApiException('Текст песни не найден');
    }

    final rawLines = _htmlToLines(container.innerHtml);
    final lines = rawLines
        .map((text) => SongLine(text: text, isChordLine: _looksLikeChordLine(text)))
        .toList();

    return SongDetails(summary: song, lines: lines);
  }

  List<String> _htmlToLines(String innerHtml) {
    final withBreaks = innerHtml.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    // Соседние теги без текста между ними (например закрывающийся блок
    // раздела и сразу открывающийся блок аккордов) иначе слипаются в одно
    // слово после снятия тегов.
    final spaced = withBreaks.replaceAll('><', '> <');
    final noTags = spaced.replaceAll(RegExp(r'<[^>]*>'), '');
    return _unescapeHtml(noTags).split('\n');
  }

  String _unescapeHtml(String text) {
    return text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  // Хвост вида "(V)"/"(VII)" — позиция баррэ, которую amdm.ru добавляет
  // к части аккордов (A(V), B(VII) и т.п.).
  static final RegExp _chordToken = RegExp(
    r'^[A-H](#|b)?(m|maj|min|sus|dim|aug|add)?[0-9]*(/[A-H](#|b)?)?(\([IVXivx0-9]+\))?$',
  );

  bool _looksLikeChordLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;
    final tokens = trimmed.split(RegExp(r'\s+'));
    if (tokens.isEmpty) return false;
    final chordTokens = tokens.where((t) => _chordToken.hasMatch(t)).length;
    return chordTokens >= (tokens.length / 2).ceil();
  }

  void dispose() => _client.close();
}
