import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _solvedKey = 'solved_puzzle_ids';
  static const _attemptedKeyPrefix = 'attempted_';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<Set<String>> getSolvedIds() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_solvedKey) ?? [];
    return list.toSet();
  }

  Future<void> markSolved(String puzzleId) async {
    final prefs = await _prefs;
    final solved = (prefs.getStringList(_solvedKey) ?? []).toSet();
    solved.add(puzzleId);
    await prefs.setStringList(_solvedKey, solved.toList());
  }

  Future<bool> hasAttempted(String puzzleId) async {
    final prefs = await _prefs;
    return prefs.getBool('$_attemptedKeyPrefix$puzzleId') ?? false;
  }

  Future<void> markAttempted(String puzzleId) async {
    final prefs = await _prefs;
    await prefs.setBool('$_attemptedKeyPrefix$puzzleId', true);
  }
}
