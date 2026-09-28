/// Краткая карточка песни в списках/поиске.
class SongSummary {
  const SongSummary({
    required this.id,
    required this.title,
    required this.artist,
    required this.link,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String artist;
  final String link;

  /// Фото исполнителя со страницы-источника, если было в разметке.
  final String? imageUrl;

  factory SongSummary.fromLink({
    required String title,
    required String artist,
    required String link,
    String? imageUrl,
  }) {
    return SongSummary(
      id: link,
      title: title,
      artist: artist,
      link: link,
      imageUrl: imageUrl,
    );
  }

  Map<String, String?> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'link': link,
        'imageUrl': imageUrl,
      };

  factory SongSummary.fromJson(Map<String, dynamic> json) => SongSummary(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String,
        link: json['link'] as String,
        imageUrl: json['imageUrl'] as String?,
      );

  @override
  bool operator ==(Object other) => other is SongSummary && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Одна строка текста песни: либо аккорды, либо слова.
class SongLine {
  const SongLine({required this.text, required this.isChordLine});

  final String text;
  final bool isChordLine;
}

/// Полный текст+аккорды песни, полученные с источника.
class SongDetails {
  const SongDetails({required this.summary, required this.lines});

  final SongSummary summary;
  final List<SongLine> lines;

  /// Уникальные аккорды, встречающиеся в песне, в порядке появления.
  List<String> get chordsUsed {
    final seen = <String>{};
    final result = <String>[];
    for (final line in lines) {
      if (!line.isChordLine) continue;
      for (final token in line.text.trim().split(RegExp(r'\s+'))) {
        if (token.isEmpty) continue;
        if (seen.add(token)) result.add(token);
      }
    }
    return result;
  }
}
