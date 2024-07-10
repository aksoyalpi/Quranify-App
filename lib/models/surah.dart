class Surah {
  final String title;
  final String arabicTitle;
  //final String recitator;
  //final String audioURL;

  Surah({required this.title, required this.arabicTitle});

  factory Surah.fromJson(Map<String, dynamic> json){
    return switch(json) {
      {
      "name_simple": String title,
      "name_arabic": String arabicTitle,
      } => Surah(title: title, arabicTitle: arabicTitle),
     _  => throw const FormatException(("Failed to load Surah.")),
    };
  }
}
