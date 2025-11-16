class Puzzle {
  final String id;
  final String fen;
  final List<String> moves;
  final int rating;
  final List<String> themes;
  final String url;

  Puzzle({
    required this.id,
    required this.fen,
    required this.moves,
    required this.rating,
    required this.themes,
    required this.url,
  });

  factory Puzzle.fromCsvRow(List<dynamic> row) {
    final id = row[4].toString();
    final fen = row[5].toString();
    final movesStr = row[6].toString();
    final rating = int.tryParse(row[1].toString()) ?? 0;
    final themesStr = row[7].toString();
    final url = row[8].toString();

    final moves = movesStr.split(' ').where((m) => m.isNotEmpty).toList();
    final themes = themesStr.split(' ').where((t) => t.isNotEmpty).toList();

    return Puzzle(
      id: id,
      fen: fen,
      moves: moves,
      rating: rating,
      themes: themes,
      url: url,
    );
  }
}
