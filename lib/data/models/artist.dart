/// Исполнитель, выведенный на главном экране.
class Artist {
  const Artist({
    required this.name,
    required this.songsLink,
    this.imageUrl,
  });

  final String name;
  final String songsLink;

  /// Фото исполнителя со страницы-источника, если было в разметке.
  final String? imageUrl;
}

/// Тематическая подборка/жанр песен.
class SongCollection {
  const SongCollection({
    required this.title,
    required this.link,
    this.imageUrl,
  });

  final String title;
  final String link;
  final String? imageUrl;
}
