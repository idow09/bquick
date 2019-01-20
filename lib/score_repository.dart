import 'package:shared_preferences/shared_preferences.dart';

class ScoreRepository {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<int> fetchHighScore() async {
    return (await _prefs).getInt('high-score-ms') ?? null;
  }

  void storeHighScore(int milliseconds) {}
}
