//import 'package:audioplayers/audioplayers.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quran_fi/consts/recitations.dart';
import 'package:quran_fi/models/recitator.dart';
import 'package:quran_fi/models/surah.dart';
import "package:quran_fi/consts/surahs.dart";
import 'package:quran_fi/services/api.dart';
import 'package:just_audio/just_audio.dart';

class SurahsProvider extends ChangeNotifier {
  // playlist with all surahs
  late final List<AudioSource> _playlist;

  // all surahs
  static final List<Surah> _surahs = List.generate(
      allSurahs.length, (index) => Surah.fromJson(allSurahs[index]));

  // all recitators
  final List<Recitator> _recitators = List.generate(
      recitations.length, (index) => Recitator.fromJson(recitations[index]));

  // Map with all sounds and their IconData
  final Map<String, IconData> _sounds = {
    "empty": Icons.cloud_off,
    "rain": Icons.cloudy_snowing,
    "beach": Icons.waves,
    "fire": Icons.local_fire_department,
    "birds": Icons.emoji_nature
  };

  // current sound index
  int _soundIndex = 0;

  // current surah playing index
  int? _currentSurahIndex;

  // current recitator (default: )
  late Recitator _currentRecitator;

  /*

    A U D I O P L A Y E R

  */

  // audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _soundPlayer = AudioPlayer();

  // durations
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  /*SurahsProvider._create() {}

  static Future<SurahsProvider> create() async {
    final surahPlaylist = List.generate(
      _surahs.length,
      (index) async {
        final url = await getRecitationUrl(1, index + 1);

        return AudioSource.uri(Uri.parse(url),
            tag: MediaItem(
                id: index.toString(),
                title: _surahs[index].title,
                album: "Quran",
                artist: _currentRecitator.name,
                artUri: Uri.file("images/quran.jpg", windows: false)));
      },
    );
  }*/

  // constructor
  SurahsProvider() {
    _currentRecitator = recitators[0];

    // Define the playlist
    /*final playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the playlist items
      children: surahPlaylist,
    );

    if (kDebugMode) print(_playlist);

    _audioPlayer.setAudioSource(playlist);*/

    listenToDuraton();
  }

  // initially not playing
  bool _isPlaying = false;

  // play the surah
  Future<void> play() async {
    final String url = await getRecitationUrl(_currentRecitator.id,
        _currentSurahIndex == null ? 1 : _currentSurahIndex! + 1);

    await _audioPlayer.stop(); // stop current song

    // initializing the AudioSource
    final audioSource = AudioSource.uri(Uri.parse(url),
        tag: MediaItem(
            id: _currentSurahIndex.toString(),
            title: _surahs[_currentSurahIndex!].title,
            album: "Quran",
            artist: _currentRecitator.name,
            artUri: Uri.file("assets/images/quran.jpg", windows: false)));

    await _audioPlayer.setAudioSource(audioSource);
    _audioPlayer.play();

    /////////////////// T E S T //////////////////////////
    await _soundPlayer.setLoopMode(LoopMode.all);
    if (_soundIndex != 0) {
      await _soundPlayer
          .setAsset("assets/audio/${_sounds.keys.elementAt(_soundIndex)}.mp3");
      _soundPlayer.play();
    }
    /////////////////// T E S T //////////////////////////

    _isPlaying = true;
    notifyListeners();
  }

  // pause current surah
  Future pause() async {
    await _audioPlayer.pause();
    await _soundPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // resume playing
  void resume() async {
    _audioPlayer.play();
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
  Future seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // play next surah
  void playNextSurah() {
    _currentDuration = Duration.zero;
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
    if (_currentDuration.inSeconds > 2) {
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

  // toggle nature sound
  void toggleSounds() async {
    await _soundPlayer.pause();
    _soundIndex++;
    if (_soundIndex >= _sounds.length) {
      _soundIndex = 0;
    } else {
      await _soundPlayer
          .setAsset("audio/${_sounds.keys.elementAt(_soundIndex)}.mp3");
      _soundPlayer.play();
    }
    notifyListeners();
  }

  // list to duration
  void listenToDuraton() {
    // listen for total duration
    _audioPlayer.durationStream.listen((newDuration) {
      _totalDuration = newDuration ?? Duration.zero;
      notifyListeners();
    });

    // listen for current duration
    _audioPlayer.positionStream.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    // listen for song is completed
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNextSurah();
      }
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
  Recitator get currentRecitator => _currentRecitator;
  IconData get soundIconData => _sounds.values.elementAt(_soundIndex);
  bool get soundOn => _soundIndex != 0;
  List<IconData> get soundIconDatas => _sounds.values.toList();
  int get soundIndex => _soundIndex;
  double get soundVolume => soundOn ? _soundPlayer.volume : 0;
  double get quranVolume => _audioPlayer.volume;

  /*

    S E T T E R S
  
  */

  set soundIndex(int index) {
    _soundPlayer.pause();
    _soundIndex = index;
    _soundPlayer.pause();
    if (_soundIndex != 0) {
      _soundPlayer
          .setAsset("assets/audio/${_sounds.keys.elementAt(_soundIndex)}.mp3")
          .then(
            (value) => _soundPlayer.play(),
          );
    }

    notifyListeners();
  }

  set currentSurahIndex(int? newIndex) {
    // update current surah index
    _currentSurahIndex = newIndex;

    if (newIndex != null) {
      play(); // play the song at the new index
    }

    // update UI
    notifyListeners();
  }

  // setter to change current recitator
  set currentRecitator(Recitator recitator) {
    _currentRecitator = recitator;
    notifyListeners();
  }

  // setter to change volume of sound
  set soundVolume(double volume) {
    _soundPlayer.setVolume(volume);
    notifyListeners();
  }

  // setter to change volume of quran
  set quranVolume(double volume) {
    _audioPlayer.setVolume(volume);
    notifyListeners();
  }
}
