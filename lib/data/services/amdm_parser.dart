import 'package:html/dom.dart';

import '../models/artist.dart';
import '../models/song.dart';

/// Чистый Dart-парсинг разметки amdm.ru — без Flutter-зависимостей.
///
/// Вынесен отдельно от [ChordsApiService], чтобы этим же кодом мог
/// пользоваться скрипт сборки (`tool/fetch_home_data.dart`), который
/// запускается обычным `dart run` на сервере (в GitHub Actions) и не может
/// импортировать `package:flutter/...`.
class AmdmParser {
  AmdmParser._();

  static const baseUrl = 'https://amdm.ru';

  /// Блок «Популярные исполнители» на главной странице.
  static List<Artist> parsePopularArtists(Document doc) {
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
      final imageUrl = _resolve(imageSrc);

      result.add(Artist(name: name, songsLink: href, imageUrl: imageUrl));
    }
    return result;
  }

  /// Блок «Аккорды песен по тематике» на главной странице.
  static List<SongCollection> parseThemeCollections(Document doc) {
    final result = <SongCollection>[];
    for (final item in doc.querySelectorAll('.b-artist-tematika__item')) {
      final link = item.querySelector('a');
      final href = link?.attributes['href'];
      final title = link?.text.trim();
      if (href == null || title == null || title.isEmpty) continue;

      final imageSrc = item.querySelector('img')?.attributes['src'];
      final imageUrl = _resolve(imageSrc);

      result.add(SongCollection(title: title, link: href, imageUrl: imageUrl));
    }
    return result;
  }

  /// Находит виджет `.b-index-top-songs__item` на главной странице по тексту
  /// его заголовка `<h3>` — так на ней размечены все три колонки
  /// («Новые подборы», «Популярные исполнители», «Популярные подборы»).
  static Element? _findWidgetByHeading(Document doc, String heading) {
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
  static List<SongSummary> parseSongRows(Document doc) {
    final byCell = _parseArtistSongCells(doc);
    if (byCell.isNotEmpty) return byCell;
    return _parseSingleArtistRows(doc);
  }

  static List<SongSummary> _parseArtistSongCells(Document doc) {
    final cells = doc.querySelectorAll('td.artist_name');
    final result = <SongSummary>[];
    for (final cell in cells) {
      final item = _trySongFromCell(cell);
      if (item != null) result.add(item);
    }
    return result;
  }

  static SongSummary? _trySongFromCell(Element cell) {
    try {
      final links = cell.querySelectorAll('a.artist');
      if (links.length < 2) return null;
      final artist = links[0].text.trim();
      final songLink = links[1];
      final title = songLink.text.trim();
      final href = songLink.attributes['href'];
      if (href == null || artist.isEmpty || title.isEmpty) return null;

      final imageSrc = cell.parent?.querySelector('td.photo img')?.attributes['src'];

      return SongSummary.fromLink(
        title: title,
        artist: artist,
        link: href,
        imageUrl: _resolve(imageSrc),
      );
    } catch (_) {
      return null;
    }
  }

  static List<SongSummary> _parseSingleArtistRows(Document doc) {
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
  static String? _impliedArtistName(Document doc) {
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
  /// остаётся построчным.
  static List<SongLine>? parseSongLines(Document doc) {
    final container = doc.querySelector('pre.podbor__text');
    if (container == null) return null;

    final rawLines = _htmlToLines(container.innerHtml);
    return rawLines
        .map((text) => SongLine(text: text, isChordLine: _looksLikeChordLine(text)))
        .toList();
  }

  static List<String> _htmlToLines(String innerHtml) {
    final withBreaks = innerHtml.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    // Соседние теги без текста между ними (например закрывающийся блок
    // раздела и сразу открывающийся блок аккордов) иначе слипаются в одно
    // слово после снятия тегов.
    final spaced = withBreaks.replaceAll('><', '> <');
    final noTags = spaced.replaceAll(RegExp(r'<[^>]*>'), '');
    return _unescapeHtml(noTags).split('\n');
  }

  static String _unescapeHtml(String text) {
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

  static bool _looksLikeChordLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;
    final tokens = trimmed.split(RegExp(r'\s+'));
    if (tokens.isEmpty) return false;
    final chordTokens = tokens.where((t) => _chordToken.hasMatch(t)).length;
    return chordTokens >= (tokens.length / 2).ceil();
  }

  static String? _resolve(String? maybeRelative) {
    if (maybeRelative == null) return null;
    return Uri.parse(baseUrl).resolve(maybeRelative).toString();
  }
}
