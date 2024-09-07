import 'package:quran_fi/consts/surahs.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/api.dart';
import 'package:quran_fi/services/service_locator.dart';

abstract class PlaylistRepository {
  Future<List<Map<String, String>>> fetchInitialPlaylist();
  Future<Map<String, String>> fetchAnotherSurah();
}

class DemoPlaylist extends PlaylistRepository {
  var _surahIndex = 0;
  static const _numberSurahs = 114;

  // all surahs
  final List<Surah> _surahs = List.generate(
      allSurahs.length, (index) => Surah.fromJson(allSurahs[index]));

  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist(
      {int length = _numberSurahs}) async {
    _surahIndex = 0;
    List<Map<String, String>> surahs = [];
    for (int i = 0; i < length; i++) {
      surahs.add(await _nextSurah());
    }
    return surahs;
  }

  @override
  Future<Map<String, String>> fetchAnotherSurah() async {
    return await _nextSurah();
  }

  Future<Map<String, String>> _nextSurah() async {
    _surahIndex++;
    final currentRecitator = getIt<PageManager>().currentRecitator.value;
    final url = await getRecitionUrl(currentRecitator.id, _surahIndex);
    print(url);
    print("_surahIndex: $_surahIndex");
    return {
      'id': _surahIndex.toString().padLeft(3, '0'),
      'title': _surahs[_surahIndex - 1].title,
      "arabicTitle": _surahs[_surahIndex - 1].arabicTitle,
      'album': 'Quran',
      'url': url,
    };
  }
}
