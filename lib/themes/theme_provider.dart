import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quran_fi/services/shared_prefs.dart';
import 'package:quran_fi/themes/dark_mode.dart';
import 'package:quran_fi/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // initially, light mode
  late ThemeData _themeData = lightMode;

  Future<void> init() async {
    final isDarkMode = await SharedPrefs.getIsDarkMode();
    _themeData = isDarkMode ?? false ? darkMode : lightMode;
    notifyListeners();
  }

  // get Theme
  ThemeData get themeData => _themeData;

  // is dark mode
  bool get isDarkMode => _themeData == darkMode;

  // set Theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // toggle theme
  void toggleTheme() {
    if (kDebugMode) print("toggled");
    if (_themeData == lightMode) {
      themeData = darkMode;
      SharedPrefs.setIsDarkMode(true);
    } else {
      SharedPrefs.setIsDarkMode(false);
      themeData = lightMode;
    }
  }
}
