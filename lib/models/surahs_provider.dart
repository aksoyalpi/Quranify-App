import 'dart:html';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:quran_fi/consts/recitations.dart';
import 'package:quran_fi/models/recitator.dart';
import 'package:quran_fi/models/surah.dart';
import "package:quran_fi/consts/surahs.dart";
import 'package:quran_fi/services/api.dart';

class SurahsProvider extends ChangeNotifier{
  // all surahs
  final List<Surah> _surahs = List.generate(allSurahs.length, (index) => Surah.fromJson(allSurahs[index]));
  
  // all recitators
  final List<Recitator> _recitators = List.generate(recitations.length, (index) => Recitator.fromJson(recitations[index]));

  // current surah playing index
  int? _currentSurahIndex;

  // current recitator (default: )
  late Recitator _currentRecitator;

  /*

    A U D I O P L A Y E R

  */

  // audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // durations
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // constructor
  SurahsProvider() {
    _currentRecitator = recitators[0];
    listenToDuraton();
  }

  // initially not playing
  bool _isPlaying = false;

  // play the surah
  void play() async {
    final String path = await getRecitionUrl(_currentRecitator.id, _currentSurahIndex ?? 0); //_surahs[_currentSurahIndex!].audioURL;
    await _audioPlayer.stop(); // stop current song
    await _audioPlayer.play(UrlSource(path));
    _isPlaying = true;
    notifyListeners();
  }

  // pause current surah
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // resume playing
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // pause or resume
  void pauseOrResume() async {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
    notifyListeners();
  }

  // seek to a specific position in the current song
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // play next surah
  void playNextSurah() {
    if (_currentSurahIndex != null) {
      if (_currentSurahIndex! < _surahs.length - 1) {
        // go to next surah if its not the last surah
        currentSurahIndex = _currentSurahIndex! + 1;
      } else {
        // if its the last surah, loop back to the first surah
        currentSurahIndex = 0;
      }
    }
  }

  // play previous surah
  void playPreviousSurah() async {
    // if more than 2sec have passed, restart the current surah
    if (_currentDuration.inSeconds < 2) {
      seek(Duration.zero);
    }
    // if its whithin 2 secons of the surah, go to previous surah
    else {
      if (_currentSurahIndex! > 0) {
        currentSurahIndex = _currentSurahIndex! - 1;
      } else {
        // if its the first surah, loop bakc to the last surah
        currentSurahIndex = _surahs.length - 1;
      }
    }
  }

  // list to duration
  void listenToDuraton() {
    // listen for total duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    // listen for current duration
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    // listen for song is completed
    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSurah();
    });
  }

  // dispose audio player

  /*

    G E T T E R S
  
  */

  List<Surah> get surahs => _surahs;
  int? get currentSurahIndex => _currentSurahIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  List<Recitator> get recitators => _recitators;

  /*

    S E T T E R S
  
  */

  set currentSurahIndex(int? newIndex) {
    // update current surah index
    _currentSurahIndex = newIndex;

    if (newIndex != null) {
      //play(); // play the song at the new index
    }

    // update UI
    notifyListeners();
  }
}
