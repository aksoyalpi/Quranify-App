import 'package:audio_service/audio_service.dart';

import 'package:flutter/material.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/models/surahs_provider.dart';

// Convert a SongModel to a MediaItem
Future<MediaItem> surahToMediaItem(Surah surah, String uri) async {
  SurahsProvider surahsProvider = SurahsProvider();
  try {
    // Create and return a MediaItem
    return MediaItem(
      // Use the song URI as the MediaItem ID
      id: uri,
      album: "Qur'an",

      // Set the artwork URI obtained earlier
      artUri: Uri.file("asset/images/quran.jpg"),

      // Format the song title using the provided utility function
      title: surah.title,

      // Set the artist, duration, and display description
      artist: surahsProvider.currentRecitator.name,
      duration: surahsProvider.totalDuration,
    );
  } catch (e) {
    // Handle any errors that occur during the process
    debugPrint('Error converting SongModel to MediaItem: $e');
    // Return a default or null MediaItem in case of an error
    return const MediaItem(id: '', title: 'Error', artist: 'Unknown');
  }
}
