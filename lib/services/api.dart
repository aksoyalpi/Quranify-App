import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quran_fi/consts/recitations.dart';
import 'package:quran_fi/models/surah.dart';

const baseURL = "https://api.quran.com/api/v4";

Future<List<Surah>> getSurahs() async {
  final url = Uri.parse("$baseURL/chapters");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final surahs = jsonDecode(response.body).chapters;
    return List.generate(
        surahs.length, (index) => Surah.fromJson(surahs[index]));
  } else {
    throw Exception("Failed to load Surahs");
  }
}

Future getRecitionUrl(int recitatorId, int surahNumber) async {
  // check if its Yasser Al-Dosar
  if (recitatorId == 92) {
    print("TEST");
    return "https://server11.mp3quran.net/yasser/${surahNumber.toString().padLeft(3, "0")}.mp3";
  } else {
    final url =
        Uri.parse("$baseURL/chapter_recitations/$recitatorId/$surahNumber");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["audio_file"]["audio_url"];
    } else {
      throw Exception("Failed to load AudioURL");
    }
  }
}
