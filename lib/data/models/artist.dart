/// Исполнитель, выведенный на главном экране.
class Artist {
  const Artist({
    required this.name,
    required this.description,
    required this.image,
    required this.songsLink,
  });

  final String name;
  final String description;
  final String image;
  final String songsLink;
}

/// Тематическая подборка/жанр песен.
class SongCollection {
  const SongCollection({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.link,
  });

  final String title;
  final String subtitle;
  final String image;
  final String link;
}
