import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<SharedPreferences> getInstance() async {
    return await SharedPreferences.getInstance();
  }

  static Future initialize() async {
    final prefs = await getInstance();
    prefs.setInt("recitator", 7);
    prefs.setBool("isDarkTheme", true);
    prefs.setStringList("favorites", []);
    prefs.setStringList("recentlyPlayed", []);
  }

  static Future<void> setDefaultRecitator(int recitatorId) async {
    final prefs = await getInstance();
    prefs.setInt("recitator", recitatorId);
  }

  /// Returns saved default recitators id
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

  static Future<void> setFavorites(List<Surah> favorites) async {
    final prefs = await getInstance();

    // List with the ids of the favorite surahs as Strings
    final favoriteIds = favorites
        .map(
          (surah) => surah.id.toString(),
        )
        .toList();

    prefs.setStringList("favorites", favoriteIds);
  }

  static Future<List<Surah>> getFavorites() async {
    final prefs = await getInstance();
    final pageManager = getIt<PageManager>();
    final favoriteIds = prefs.getStringList("favorites");

    if (favoriteIds != null) {
      return favoriteIds
          .map((id) => pageManager.surahs[int.parse(id) - 1])
          .toList();
    } else {
      return [];
    }
  }

  static Future<void> setRecentlyPlayed(List<Surah> recentlyPlayed) async {
    final prefs = await getInstance();

    // List with the ids of the recently played surahs as Strings
    final recentlyPlayedIds = recentlyPlayed
        .map(
          (surah) => surah.id.toString(),
        )
        .toList();

    prefs.setStringList("recentlyPlayed", recentlyPlayedIds);
  }

  static Future<List<Surah>> getRecentlyPlayed() async {
    final prefs = await getInstance();
    final pageManager = getIt<PageManager>();
    final recentlyPlayedIds = prefs.getStringList("recentlyPlayed");

    if (recentlyPlayedIds != null) {
      return recentlyPlayedIds
          .map((id) => pageManager.surahs[int.parse(id) - 1])
          .toList();
    } else {
      return [];
    }
  }

  /// Shared prefs variable that returns true if the user is opening the app for the first time
  /// crucial for the app onboarding tutorial
  static Future<void> setIsFirstTime(bool isFirstTime) async {
    final prefs = await getInstance();
    prefs.setBool("isFirstTime", isFirstTime);
  }

  static Future<bool> getIsFirstTime() async {
    final prefs = await getInstance();
    return prefs.getBool("isFirstTime") ?? true;
  }

  // variable to count the times the user opened the app
  // important for asking for feedback
  static Future<void> setAppOpenedCount(int count) async {
    final prefs = await getInstance();
    prefs.setInt("appOpenedCount", count);
  }

  /// Returns saved default recitators id
  static Future<int> getAppOpenedCount() async {
    final prefs = await getInstance();
    return prefs.getInt("appOpenedCount") ?? 0;
  }
}
