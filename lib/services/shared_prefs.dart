import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<SharedPreferences> getInstance() async {
    return await SharedPreferences.getInstance();
  }

  static Future<void> setDefaultRecitator(int recitatorId) async {
    final prefs = await getInstance();
    prefs.setInt("recitator", recitatorId);
  }

  static Future<int?> getDefaultRecitator() async {
    final prefs = await getInstance();
    return prefs.getInt("recitator");
  }

  static Future<void> setIsDarkMode(bool isDarkMode) async {
    final prefs = await getInstance();
    prefs.setBool("isDarkTheme", isDarkMode);
  }

  static Future<bool?> getIsDarkMode() async {
    final prefs = await getInstance();
    return prefs.getBool("isDarkTheme");
  }
}
