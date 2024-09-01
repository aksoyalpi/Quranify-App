import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<SharedPreferences> getInstance() async {
    return await SharedPreferences.getInstance();
  }

  static setDefaultRecitator(String recitator) async {
    final prefs = await getInstance();
    prefs.setString("recitator", recitator);
  }

  static getDefaultRecitator() async {
    final prefs = await getInstance();
    return prefs.getString("recitator");
  }
}
