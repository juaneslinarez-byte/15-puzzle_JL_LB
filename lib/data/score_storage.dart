import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/difficulty.dart';
import '../logic/high_score.dart';

class ScoreStorage {
  static const _prefix = 'score_';

  Future<HighScore?> read(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix${difficulty.name}');
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return HighScore.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(Difficulty difficulty, HighScore score) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(score.toJson());
    await prefs.setString('$_prefix${difficulty.name}', raw);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final d in Difficulty.values) {
      await prefs.remove('$_prefix${d.name}');
    }
  }
}