import 'package:flutter/foundation.dart' show kIsWeb;

/// Оборачивает внешний URL через публичный CORS-прокси, если приложение
/// собрано под веб (там браузер блокирует прямые запросы к amdm.ru).
/// На Android/iOS/desktop такого ограничения нет, поэтому URL возвращается
/// как есть.
String withCorsProxyIfWeb(String url) {
  if (!kIsWeb) return url;
  return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
}
