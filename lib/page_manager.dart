import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quran_fi/consts/recitations.dart';
import 'package:quran_fi/consts/surahs.dart';
import 'package:quran_fi/models/recitator.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/notifiers/repeat_mode_notifer.dart';
import 'package:quran_fi/services/api.dart';
import 'package:quran_fi/services/shared_prefs.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'services/service_locator.dart';
import 'package:just_audio/just_audio.dart';

class PageManager {
  final _audioHandler = getIt<AudioHandler>();
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final repeatModeNotifier = RepeatModeNotifer();
  final currentRecitator = ValueNotifier<Recitator>(Recitator.fromJson(
      recitations.toList().firstWhere(
          (reciter) => reciter["id"] == 7))); // Mishary Rashid Al-Afasy
  final currentSoundIndex = ValueNotifier<int>(0);
  final quranVolume = ValueNotifier<double>(1);
  final soundVolume = ValueNotifier<double>(1);
  final favoritesNotifier = ValueNotifier<List<Surah>>([]);
  final recentlyPlayedNotifier = ValueNotifier<List<Surah>>([]);
  final isChooseMode = ValueNotifier<bool>(false);
  final choosedSurahs = ValueNotifier<List<Surah>>([]);
  final sleepTimer = ValueNotifier<int>(0);
  Timer? _timer;

  List<MediaItem> get playlist => _audioHandler.queue.value;

  // all surahs
  final List<Surah> _surahs = List.generate(
      allSurahs.length, (index) => Surah.fromJson(allSurahs[index]));

  // all recitators
  final List<Recitator> _recitators = List.generate(
      recitations.length, (index) => Recitator.fromJson(recitations[index]));

// Method to set sleep timer, so that audio stops automatically after given time
  void setSleepTimer(int minutes) {
    _audioHandler.customAction("setSleepTimer", {"minutes": minutes});
    sleepTimer.value = minutes;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        sleepTimer.value--;
        if (sleepTimer.value == 0) timer.cancel();
      },
    );
  }

// choose Surah function for choose mode
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

// activated/deactivates choose mode
  void switchChooseMode() {
    isChooseMode.value = !isChooseMode.value;
    if (!isChooseMode.value) {
      choosedSurahs.value.clear();
    }
  }

  Future _initFavorites() async {
    favoritesNotifier.value = await SharedPrefs.getFavorites();
  }

  Future _initRecentlyPlayed() async {
    recentlyPlayedNotifier.value = await SharedPrefs.getRecentlyPlayed();
  }

  // updates favorites list to newFavorites parameter
  Future changeFavorites(List<Surah> newFavorites) async {
    favoritesNotifier.value = newFavorites.toList();
    await SharedPrefs.setFavorites(newFavorites);
  }

  /// will add chosen surahs to favorites if one of the chosen surahs is not already in favorites
  /// else it will remove all chosen surahs from favorites
  Future addChosenSurahsToFavorites() async {
    final favorites = favoritesNotifier.value;
    final chosen = choosedSurahs.value;

    // returns true if all surahs are already in favorites
    bool allInFavorites = !chosen.every(
      (surah) => !favorites.contains(surah),
    );

    if (allInFavorites) {
      favorites.removeWhere((surah) => chosen.contains(surah));
    } else {
      chosen.removeWhere((surah) => favorites.contains(surah));
      favoritesNotifier.value.addAll(choosedSurahs.value);
    }

    changeFavorites(favoritesNotifier.value);
  }

  Future<void> changeRecitator(int id) async {
    currentRecitator.value = _recitators.firstWhere(
      (element) => element.id == id,
    );

    stop();
    await _loadNewPlaylist();
    play();
  }

  Future<void> _initDefaultRecitator() async {
    final int? defaultRecitatorId = await SharedPrefs.getDefaultRecitator();
    if (defaultRecitatorId == null) {
      currentRecitator.value = Recitator.fromJson(
          recitations.toList().firstWhere((reciter) => reciter["id"] == 7));
    } else {
      setDefaultRecitator(defaultRecitatorId, init: true);
    }
  }

  /// Method to change the default recitator by the id of the recitator
  Future<void> setDefaultRecitator(int recitatorId, {bool init = false}) async {
    currentRecitator.value = recitators.firstWhere(
      (recitator) => recitator.id == recitatorId,
    );

    if (!init) {
      stop();
      await _loadNewPlaylist();
      play();
    }
  }

  Future _loadNewPlaylist() async {
    final recitator = currentRecitator.value;

    final newMediaItems = playlist.map((item) async {
      final url = await getRecitionUrl(recitator.id, int.parse(item.id));

      return MediaItem(
          id: item.id,
          title: item.title,
          album: item.album,
          artist: recitator.name,
          artUri: item.artUri,
          extras: {
            "url": url,
            "arabicTitle": item.extras?["arabicTitle"] ?? ""
          });
    }).toList();

    await _audioHandler.customAction("removeAll");

    for (var element in newMediaItems) {
      await _audioHandler.addQueueItem(await element);
    }
  }

  void setSoundIndex(int index) async {
    currentSoundIndex.value = index;
    _audioHandler.customAction("setSoundIndex", {"index": index});
  }

  void setSoundVolume(double volume) {
    soundVolume.value = volume;
    _audioHandler.customAction("setSoundVolume", {"volume": volume});
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
      } else {
        final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((Duration position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
          current: oldState.current,
          buffered: playbackState.bufferedPosition,
          total: oldState.total);
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) async {
      final oldState = progressNotifier.value;

      // work around to get surahs duration
      final tmpPlayer = AudioPlayer();
      final Duration? duration =
          await tmpPlayer.setUrl(mediaItem?.extras?["url"]);

      tmpPlayer.dispose();
      progressNotifier.value = ProgressBarState(
          current: oldState.current,
          buffered: oldState.buffered,
          total: duration ?? Duration(hours: 1));
    });
  }

  void _listenToChangesInSurah() {
    _audioHandler.mediaItem.listen((mediaItem) async {
      if (mediaItem != null &&
          currentSongTitleNotifier.value != mediaItem.title) {
        final recentlyPlayed = recentlyPlayedNotifier.value;

        // checks weither mediaItem is already in recently played list
        if (recentlyPlayed.any(
          (element) => element.id == int.parse(mediaItem.id),
        )) {
          recentlyPlayed.removeWhere(
            (element) => element.id == int.parse(mediaItem.id),
          );
        } else if (recentlyPlayed.length > 4) {
          recentlyPlayed.removeLast();
        }
        recentlyPlayed.insert(0, Surah.fromMediaItem(mediaItem));
        SharedPrefs.setRecentlyPlayed(recentlyPlayed);
        recentlyPlayedNotifier.value = recentlyPlayed.toList();
      }

      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  // Events: Calls coming from the UI
  void init() async {
    _initDefaultRecitator();
    _initFavorites();
    _initRecentlyPlayed();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSurah();
  }

  Future playSurah(Surah surah) async {
    stop();
    bool inPlaylist = false;

    // checks if surah is already in playlist
    for (var mediaItem in playlist) {
      int.parse(mediaItem.id) == surah.id ? inPlaylist = true : null;
    }

    if (inPlaylist) {
      // returns the item(Surah) that already is in the playlist
      final itemInPlaylist = playlist
          .firstWhere((mediaItem) => int.parse(mediaItem.id) == surah.id);

      // returns the index of the item in the playlist
      int indexOfSurah = _audioHandler.queue.value.indexOf(itemInPlaylist);
      _audioHandler.skipToQueueItem(indexOfSurah);
    } else {
      await add(surah, placeAtCurrentPosition: true);

      if (playlist.length > 1) {
        next();
      }
    }
    play();
  }

  void setQuranVolume(double volume) {
    _audioHandler.customAction("setVolume", {"volume": volume});
    quranVolume.value = volume;
  }

  void play() {
    _audioHandler.play();
  }

  void pause() {
    _audioHandler.pause();
  }

  void seek(Duration position) => _audioHandler.seek(position);
  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  void repeat() {
    final currentRepeatMode = repeatModeNotifier.value;
    switch (currentRepeatMode) {
      case RepeatModeState.none:
        repeatModeNotifier.value = RepeatModeState.all;
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
      case RepeatModeState.all:
        repeatModeNotifier.value = RepeatModeState.one;
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatModeState.one:
        repeatModeNotifier.value = RepeatModeState.none;
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  /// adds new Surah to Playlist
  /// returns true if the surah was already in the playlist
  Future<bool> add(Surah surah,
      {bool placeAtCurrentPosition = false, int? index}) async {
    final url = await getRecitionUrl(currentRecitator.value.id, surah.id);
    final playlist = _audioHandler.queue.value;
    final MediaItem item = MediaItem(
        id: surah.id.toString().padLeft(3, "0"),
        album: currentRecitator.value.name,
        title: surah.title,
        artUri: Uri.parse(
            "https://images.unsplash.com/photo-1576764402988-7143f9cca90a?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
        extras: {"url": url, "arabicTitle": surah.arabicTitle});

    bool inPlaylist = false;

    // checks if surah is already in playlist
    for (var mediaItem in playlist) {
      int.parse(mediaItem.id) == surah.id ? inPlaylist = true : null;
    }

    if (inPlaylist) return true;

    if (placeAtCurrentPosition) {
      MediaItem? current = _audioHandler.mediaItem.value;

      // checks if there is already a item playing (in the queue) or not
      if (current == null) {
        await _audioHandler.addQueueItem(item);
      } else {
        int currentIndex =
            _audioHandler.queue.value.indexOf(_audioHandler.mediaItem.value!);

        await _audioHandler.insertQueueItem(currentIndex + 1, item);
      }
    } else if (index == null || index < 0) {
      await _audioHandler.addQueueItem(item);
    } else {
      await _audioHandler.insertQueueItem(index, item);
    }
    return false;
  }

  /// Function to add chosen surahs (from choose mode) to playlist
  Future addChosenSurahs() async {
    for (final surah in choosedSurahs.value) {
      add(surah);
    }
  }

  Future<void> remove(Surah surah) async {
    final playlist = _audioHandler.queue.value;

    final itemInPlaylist =
        playlist.firstWhere((mediaItem) => int.parse(mediaItem.id) == surah.id);

    // returns the index of the item in the playlist
    int indexOfSurah = playlist.indexOf(itemInPlaylist);

    await _audioHandler.removeQueueItemAt(indexOfSurah);
  }

  /// Method to clear playlist
  Future removeAll() async {
    await _audioHandler.customAction("clear");
    currentSongTitleNotifier.value = "";
    playlistNotifier.value = [];
  }

  Future move(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex--;
    }
    await _audioHandler
        .customAction("move", {"oldIndex": oldIndex, "newIndex": newIndex});
  }

  void dispose() {
    _audioHandler.customAction("dispose");
  }

  void stop() {
    _audioHandler.stop();
  }

  // GETTERS

  List<Surah> get surahs => _surahs;
  List<Recitator> get recitators => _recitators;
}
