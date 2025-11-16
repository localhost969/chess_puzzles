import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

import '../models/puzzle.dart';

class PuzzleRepository {
  Future<List<Puzzle>> loadPuzzles() async {
    final csvString = await rootBundle.loadString('assets_db.csv');
    final rows = const CsvToListConverter().convert(csvString, eol: '\n');

    return rows
        .where((row) => row.isNotEmpty)
        .map((row) => Puzzle.fromCsvRow(row))
        .toList();
  }
}
