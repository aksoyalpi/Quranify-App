import 'package:flutter/material.dart';
import 'package:quran_fi/models/surah.dart';

class SurahsProvider extends ChangeNotifier {
  // all surahs
  final List<Surah> _surahs = [
    // Test
    Surah(
        title: "Al-Fatiha",
        recitator: "Abdullah 3awwad Al-Juhaynee",
        audioURL:
            "https://download.quranicaudio.com/quran/abdullaah_3awwaad_al-juhaynee//001.mp3")
  ];

  // current surah playing index
  int? _currentSurahIndex;

  /*
  G E T T E R S
  */

  List<Surah> get surahs => _surahs;
  int? get currentSurahIndex => _currentSurahIndex;

  /*
  S E T T E R S
  */

  set currentSurahIndex(int? newIndex) {
    // update current surah index
    _currentSurahIndex = newIndex;

    // update UI
    notifyListeners();
  }
}
