import 'package:shared_preferences/shared_preferences.dart';

class ScoreRepository {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<int> fetchHighScore() async {
    return (await _prefs).getInt('high-score-ms');
  }

  Future<void> storeHighScore(int milliseconds) async {
    (await _prefs).setInt('high-score-ms', milliseconds);
  }
}
