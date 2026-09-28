import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

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
  static const _baseUrl = 'https://3akkorda.net';
  static const _timeout = Duration(seconds: 12);

  Future<Document> _getDocument(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } catch (_) {
      throw ChordsApiException('Не удалось подключиться к серверу');
    }
    if (response.statusCode != 200) {
      throw ChordsApiException('Сервер вернул ошибку ${response.statusCode}');
    }
    return html_parser.parse(response.body);
  }

  /// Список песен на странице поиска/каталога [page], опционально
  /// отфильтрованный по [query].
  Future<List<SongSummary>> fetchSongsPage({
    required int page,
    String? query,
  }) async {
    final uri = (query == null || query.isEmpty)
        ? Uri.parse('$_baseUrl/page/$page/')
        : Uri.parse('$_baseUrl/page/$page/?s=${Uri.encodeQueryComponent(query)}');
    final doc = await _getDocument(uri);
    return _parseSongCards(doc);
  }

  /// Список песен по произвольной ссылке коллекции/исполнителя.
  Future<List<SongSummary>> fetchSongsFromLink(String link) async {
    final doc = await _getDocument(Uri.parse(link));
    return _parseSongCards(doc);
  }

  List<SongSummary> _parseSongCards(Document doc) {
    final cards = doc.getElementsByClassName('post-inner post-hover');
    final result = <SongSummary>[];
    for (final card in cards) {
      final item = _trySummaryFromCard(card);
      if (item != null) result.add(item);
    }
    return result;
  }

  SongSummary? _trySummaryFromCard(Element card) {
    try {
      final titleLink = card.querySelector('a[title]') ?? card.querySelector('a');
      if (titleLink == null) return null;
      final rawTitle = (titleLink.attributes['title'] ?? titleLink.text).trim();
      final href = titleLink.attributes['href'];
      if (href == null || !rawTitle.contains('–')) return null;

      final parts = rawTitle.split(' – ');
      if (parts.length < 2) return null;
      final artist = parts.first.trim();
      final title = parts.sublist(1).join(' – ').trim();
      if (artist.isEmpty || title.isEmpty) return null;

      return SongSummary.fromLink(title: title, artist: artist, link: href);
    } catch (_) {
      return null;
    }
  }

  /// Полный текст с аккордами для конкретной песни.
  Future<SongDetails> fetchSongDetails(SongSummary song) async {
    final doc = await _getDocument(Uri.parse(song.link));
    final verse = doc.getElementsByClassName('verse');
    if (verse.isEmpty) {
      throw ChordsApiException('Текст песни не найден');
    }

    final rawLines = _htmlToLines(verse.first.innerHtml);
    final lines = rawLines
        .map((text) => SongLine(text: text, isChordLine: _looksLikeChordLine(text)))
        .toList();

    return SongDetails(summary: song, lines: lines);
  }

  List<String> _htmlToLines(String innerHtml) {
    final withBreaks = innerHtml.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    final noTags = withBreaks.replaceAll(RegExp(r'<[^>]*>'), '');
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

  static final RegExp _chordToken = RegExp(
    r'^[A-H](#|b)?(m|maj|min|sus|dim|aug|add)?[0-9]*(/[A-H](#|b)?)?$',
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
