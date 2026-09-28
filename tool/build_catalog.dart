// Серверный скрипт сборки (запускается `dart run` в GitHub Actions,
// не входит в само приложение). Собирает каталог для просмотра —
// исполнителей, тематические подборки и списки их песен (только
// названия/ссылки/обложки, БЕЗ текста песен) — прямо с amdm.ru, пока
// сборка идёт на сервере (там нет браузерных ограничений CORS).
// Результат кладётся в web/data/catalog.json и подключается
// flutter build web как обычный статический файл.
//
// Почему без текста: кэшировать и публично раздавать статическим файлом
// сами тексты песен (а не только их названия) означало бы держать
// объёмную копию чужого контента на открытом URL — в отличие от
// разового запроса "на просмотр одной песни", это уже похоже на
// раздачу базы данных. Поэтому текст+аккорды конкретной песни
// приложение по-прежнему запрашивает у amdm.ru в момент, когда
// пользователь её открывает (см. ChordsApiService).
//
// Чистый Dart, без Flutter.

import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'package:gitars_app/data/models/song.dart';
import 'package:gitars_app/data/services/amdm_parser.dart';

/// Сколько песен брать из каждого источника (исполнитель/подборка/топ).
const _perSourceLimit = 16;

Future<void> main() async {
  final client = http.Client();
  try {
    stdout.writeln('Fetching homepage…');
    final homeDoc = await _getDoc(client, AmdmParser.baseUrl);
    final artists = AmdmParser.parsePopularArtists(homeDoc);
    final collections = AmdmParser.parseThemeCollections(homeDoc);
    stdout.writeln('  ${artists.length} artists, ${collections.length} collections');

    final allSongs = <String, SongSummary>{};
    final bySourceLink = <String, List<String>>{};

    stdout.writeln('Fetching popular songs…');
    final popularDoc = await _getDoc(client, '${AmdmParser.baseUrl}/akkordi/popular/');
    final popularSongs =
        AmdmParser.parseSongRows(popularDoc).take(_perSourceLimit * 2).toList();
    bySourceLink['popular'] = [];
    for (final s in popularSongs) {
      allSongs[s.id] = s;
      bySourceLink['popular']!.add(s.id);
    }
    stdout.writeln('  ${popularSongs.length} songs');

    for (final artist in artists) {
      stdout.writeln('Fetching songs for ${artist.name}…');
      try {
        final doc = await _getDoc(client, artist.songsLink);
        final songs = AmdmParser.parseSongRows(doc).take(_perSourceLimit).toList();
        bySourceLink[artist.songsLink] = [];
        for (final s in songs) {
          allSongs[s.id] = s;
          bySourceLink[artist.songsLink]!.add(s.id);
        }
        stdout.writeln('  ${songs.length} songs');
      } catch (e) {
        stderr.writeln('  failed: $e');
      }
    }

    for (final collection in collections) {
      stdout.writeln('Fetching songs for ${collection.title}…');
      try {
        final doc = await _getDoc(client, collection.link);
        final songs = AmdmParser.parseSongRows(doc).take(_perSourceLimit).toList();
        bySourceLink[collection.link] = [];
        for (final s in songs) {
          allSongs[s.id] = s;
          bySourceLink[collection.link]!.add(s.id);
        }
        stdout.writeln('  ${songs.length} songs');
      } catch (e) {
        stderr.writeln('  failed: $e');
      }
    }

    stdout.writeln('Total unique songs: ${allSongs.length}');

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
      'songs': allSongs.values.map((s) => s.toJson()).toList(),
      'bySourceLink': bySourceLink,
    };

    final file = File('web/data/catalog.json');
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(data));
    final sizeKb = (await file.length()) ~/ 1024;

    stdout.writeln(
      'Wrote ${file.path} ($sizeKb KB): ${artists.length} artists, '
      '${collections.length} collections, ${allSongs.length} songs',
    );

    if (artists.isEmpty || collections.isEmpty || allSongs.isEmpty) {
      stderr.writeln('Warning: one of the sections came back empty — check amdm.ru markup.');
    }
  } finally {
    client.close();
  }
}

Future<Document> _getDoc(http.Client client, String url) async {
  final response = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode} for $url');
  }
  return html_parser.parse(response.body);
}
