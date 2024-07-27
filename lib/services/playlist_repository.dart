import 'package:quran_fi/consts/recitations.dart';
import 'package:quran_fi/consts/surahs.dart';
import 'package:quran_fi/models/recitator.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/services/api.dart';

abstract class PlaylistRepository {
  Future<List<Map<String, String>>> fetchInitialPlaylist();
  Future<Map<String, String>> fetchAnotherSurah();
}

class DemoPlaylist extends PlaylistRepository {
  // all surahs
  final List<Surah> _surahs = List.generate(
      allSurahs.length, (index) => Surah.fromJson(allSurahs[index]));

  // all recitators
  final List<Recitator> _recitators = List.generate(
      recitations.length, (index) => Recitator.fromJson(recitations[index]));

  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist(
      {int length = _numberSurahs}) async {
    print("Lak geht das nicht");
    List<Future<Map<String, String>>> futures = List.generate(
      length - 1,
      (index) => _nextSurah(),
    );

    return await Future.wait(futures);
  }

  @override
  Future<Map<String, String>> fetchAnotherSurah() async {
    return _nextSurah();
  }

  var _surahIndex = 0;
  static const _numberSurahs = 114;

  Future<Map<String, String>> _nextSurah() async {
    _surahIndex++;
    final url = await getRecitionUrl(1, _surahIndex);
    print(url);
    return {
      'id': _surahIndex.toString().padLeft(3, '0'),
      'title': _surahs[_surahIndex].title,
      'album': 'Quran',
      "artUri": "asset/image/quran.jpg",
      'url': url,
    };
  }
}
