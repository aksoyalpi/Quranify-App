import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quran_fi/models/surah.dart';

const baseURL = "https://api.quran.com/api/v4";

Future<List<Surah>> getSurahs() async {
  final url = Uri.parse("$baseURL/chapters");
  final response = await http.get(url);

  if(response.statusCode == 200){
    final surahs = jsonDecode(response.body).chapters;
    return List.generate(surahs.length, (index) => Surah.fromJson(surahs[index]));
  } else {
    throw Exception("Failed to load Surahs");
  }
}