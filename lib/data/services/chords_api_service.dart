import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../models/artist.dart';
import '../models/song.dart';
import 'amdm_parser.dart';

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
/// модели через [AmdmParser]. Здесь — только сетевая часть: получить HTML.
class ChordsApiService {
  ChordsApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = AmdmParser.baseUrl;
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
    return AmdmParser.parseSongRows(doc);
  }

  /// Список песен по произвольной ссылке исполнителя/подборки/темы —
  /// на amdm.ru все они используют одну и ту же вёрстку списка.
  Future<List<SongSummary>> fetchSongsFromLink(String link) async {
    final doc = await _getDocument(Uri.parse(link));
    return AmdmParser.parseSongRows(doc);
  }

  /// Блок «Популярные исполнители» на главной странице amdm.ru.
  Future<List<Artist>> fetchPopularArtists() async {
    final doc = await _getDocument(Uri.parse(_baseUrl));
    return AmdmParser.parsePopularArtists(doc);
  }

  /// Блок «Аккорды песен по тематике» на главной странице amdm.ru.
  Future<List<SongCollection>> fetchThemeCollections() async {
    final doc = await _getDocument(Uri.parse(_baseUrl));
    return AmdmParser.parseThemeCollections(doc);
  }

  /// Полный текст с аккордами для конкретной песни.
  Future<SongDetails> fetchSongDetails(SongSummary song) async {
    final doc = await _getDocument(Uri.parse(song.link));
    final lines = AmdmParser.parseSongLines(doc);
    if (lines == null) {
      throw ChordsApiException('Текст песни не найден');
    }
    return SongDetails(summary: song, lines: lines);
  }

  void dispose() => _client.close();
}
