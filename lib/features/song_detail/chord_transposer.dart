/// Транспонирование аккордов на заданное число полутонов.
class ChordTransposer {
  ChordTransposer._();

  static const List<String> _sharpScale = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];
  static const Map<String, String> _flatToSharp = {
    'Db': 'C#', 'Eb': 'D#', 'Gb': 'F#', 'Ab': 'G#', 'Bb': 'A#', 'Hb': 'A#',
    'H': 'B',
  };

  static final RegExp _rootPattern = RegExp(r'^[A-H](#|b)?');

  static String transposeLine(String line, int semitones) {
    if (semitones == 0) return line;
    return line.replaceAllMapped(
      RegExp(r'\S+'),
      (match) => _transposeToken(match.group(0)!, semitones),
    );
  }

  static String _transposeToken(String token, int semitones) {
    final match = _rootPattern.firstMatch(token);
    if (match == null) return token;

    final root = match.group(0)!;
    final rest = token.substring(root.length);
    final normalizedRoot = _flatToSharp[root] ?? root;
    final index = _sharpScale.indexOf(normalizedRoot);
    if (index == -1) return token;

    final newIndex = ((index + semitones) % 12 + 12) % 12;
    return _sharpScale[newIndex] + rest;
  }
}
