// Серверный скрипт (запускается `dart run` в GitHub Actions при сборке,
// не входит в само приложение). Он забирает данные для Главного экрана
// напрямую с amdm.ru — без CORS-ограничений браузера — и сохраняет их
// как обычный JSON-файл внутрь web/, откуда flutter build web включит
// его в сборку. Веб-приложение читает этот файл с того же домена
// (github.io), поэтому никакого прокси там уже не нужно.
//
// Чистый Dart, без Flutter — импортирует только http/html и AmdmParser.

import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'package:gitars_app/data/services/amdm_parser.dart';

Future<void> main() async {
  final client = http.Client();
  try {
    final homeDoc = html_parser.parse(
      (await client.get(Uri.parse(AmdmParser.baseUrl))).body,
    );
    final popularDoc = html_parser.parse(
      (await client.get(Uri.parse('${AmdmParser.baseUrl}/akkordi/popular/'))).body,
    );

    final artists = AmdmParser.parsePopularArtists(homeDoc);
    final collections = AmdmParser.parseThemeCollections(homeDoc);
    final songs = AmdmParser.parseSongRows(popularDoc);

    final data = {
      'fetchedAt': DateTime.now().toUtc().toIso8601String(),
      'artists': artists
          .map((a) => {
                'name': a.name,
                'songsLink': a.songsLink,
                'imageUrl': a.imageUrl,
              })
          .toList(),
      'collections': collections
          .map((c) => {
                'title': c.title,
                'link': c.link,
                'imageUrl': c.imageUrl,
              })
          .toList(),
      'songs': songs.map((s) => s.toJson()).toList(),
    };

    final file = File('web/data/home.json');
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(data));

    stdout.writeln(
      'Wrote ${file.path}: ${artists.length} artists, '
      '${collections.length} collections, ${songs.length} songs',
    );

    if (artists.isEmpty || collections.isEmpty || songs.isEmpty) {
      stderr.writeln('Warning: one of the sections came back empty — check amdm.ru markup.');
    }
  } finally {
    client.close();
  }
}
