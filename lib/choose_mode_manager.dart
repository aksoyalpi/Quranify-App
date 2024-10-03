import 'package:flutter/material.dart';
import 'package:quran_fi/models/surah.dart';

/// State Manager for Choose Mode on Surah Page
/// Choose Mode is activated when long pressing on an surah icon
class ChooseModeManager {
  final isChooseMode = ValueNotifier<bool>(false);
  final choosedSurahs = ValueNotifier<List<Surah>>([]);

  void chooseSurah(Surah surah) {
    if (isChooseMode.value) {
      if (choosedSurahs.value.contains(surah)) {
        choosedSurahs.value.remove(surah);
      } else {
        choosedSurahs.value.add(surah);
      }
      choosedSurahs.value = choosedSurahs.value.toList();
    }
  }

  void switchChooseMode() {
    isChooseMode.value = !isChooseMode.value;
    if (!isChooseMode.value) {
      choosedSurahs.value.clear();
    }
  }
}
