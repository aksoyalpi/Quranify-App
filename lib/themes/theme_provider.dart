import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quran_fi/themes/dark_mode.dart';
import 'package:quran_fi/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // initially, light mode
  ThemeData _themeData = lightMode;

  // get Theme
  ThemeData get themeData => _themeData;

  // is dark mode
  bool get isDarkMode => _themeData == darkMode;

  // set Theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    if (kDebugMode) print("switched");
    notifyListeners();
  }

  // toggle theme
  void toggleTheme() {
    if (kDebugMode) print("toggled");
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
