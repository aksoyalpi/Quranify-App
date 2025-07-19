import 'package:audio_service/audio_service.dart';

class Surah {
  final int id; // index/number of surah
  final String title;
  final String arabicTitle;
  //final String recitator;
  //final String audioURL;

  Surah({required this.id, required this.title, required this.arabicTitle});

  factory Surah.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": int id,
        "name_simple": String title,
        "name_arabic": String arabicTitle,
      } =>
        Surah(id: id, title: title, arabicTitle: arabicTitle),
      _ => throw const FormatException(("Failed to load Surah.")),
    };
  }

  factory Surah.fromMediaItem(MediaItem mediaItem) {
    return Surah(
        id: int.parse(mediaItem.id),
        title: mediaItem.title,
        arabicTitle: mediaItem.extras?["arabicTitle"] ?? "");
  }
}
