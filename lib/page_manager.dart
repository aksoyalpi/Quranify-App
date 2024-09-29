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
          (reciter) => reciter["id"] == 92))); // Mishari Rashid al-Afasy
  final currentSoundIndex = ValueNotifier<int>(0);
  final quranVolume = ValueNotifier<double>(1);
  final soundVolume = ValueNotifier<double>(1);
  final favoritesNotifier = ValueNotifier<List<Surah>>([]);
  final recentlyPlayedNotifier = ValueNotifier<List<Surah>>([]);

  List<MediaItem> get playlist => _audioHandler.queue.value;

  // all surahs
  final List<Surah> _surahs = List.generate(
      allSurahs.length, (index) => Surah.fromJson(allSurahs[index]));

  // all recitators
  final List<Recitator> _recitators = List.generate(
      recitations.length, (index) => Recitator.fromJson(recitations[index]));

  Future _initFavorites() async {
    favoritesNotifier.value = await SharedPrefs.getFavorites();
  }

  Future _initRecentlyPlayed() async {
    recentlyPlayedNotifier.value = await SharedPrefs.getRecentlyPlayed();
  }

  Future changeFavorites(List<Surah> newFavorites) async {
    favoritesNotifier.value = newFavorites;
    await SharedPrefs.setFavorites(newFavorites);
  }

  Future<void> changeRecitator(int id) async {
    currentRecitator.value = _recitators.firstWhere(
      (element) => element.id == id,
    );

    print("recitator: ${currentRecitator.value.id}");
    stop();
    await _loadNewPlaylist();
    play();
  }

  Future<void> _initDefaultRecitator() async {
    final int? defaultRecitatorId = await SharedPrefs.getDefaultRecitator();
    if (defaultRecitatorId == null) {
      currentRecitator.value = recitators[6];
    } else {
      setDefaultRecitator(defaultRecitatorId, init: true);
    }
  }

  /**
   * Method to change the default recitator by the id of the recitator
   */
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

      print(url);

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
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((PlaybackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
          current: oldState.current,
          buffered: PlaybackState.bufferedPosition,
          total: oldState.total);
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
          current: oldState.current,
          buffered: oldState.buffered,
          total: mediaItem?.duration ?? Duration.zero);
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
          print("Alread in list: ${mediaItem.title}");
          recentlyPlayed.removeWhere(
            (element) => element.id == int.parse(mediaItem.id),
          );
        } else if (recentlyPlayed.length > 4) {
          recentlyPlayed.removeLast();
        }
        recentlyPlayed.insert(0, Surah.fromMediaItem(mediaItem));
        SharedPrefs.setRecentlyPlayed(recentlyPlayed);
        recentlyPlayedNotifier.value = recentlyPlayed;
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

  void playSurah(Surah surah) async {
    stop();
    bool inPlaylist = false;

    // checks if surah is already in playlist
    playlist.forEach((mediaItem) =>
        int.parse(mediaItem.id) == surah.id ? inPlaylist = true : null);

    if (inPlaylist) {
      // returns the item(Surah) that already is in the playlist
      final itemInPlaylist = playlist
          .firstWhere((mediaItem) => int.parse(mediaItem.id) == surah.id);

      // returns the index of the item in the playlist
      int indexOfSurah = _audioHandler.queue.value.indexOf(itemInPlaylist);
      print("index: $indexOfSurah");
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
        album: "Quran",
        title: surah.title,
        artUri: Uri.parse(
            "https://images.unsplash.com/photo-1576764402988-7143f9cca90a?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
        extras: {"url": url, "arabicTitle": surah.arabicTitle});

    //TODO does not work yet (if a surah is already in the playlist it should not be put again in the playlist)
    /*if (!playlist.contains(item)) {
      _audioHandler.addQueueItem(item);
    }*/
    bool inPlaylist = false;

    // checks if surah is already in playlist
    playlist.forEach((mediaItem) =>
        int.parse(mediaItem.id) == surah.id ? inPlaylist = true : null);

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

  void remove(Surah surah) {
    final playlist = _audioHandler.queue.value;

    final itemInPlaylist =
        playlist.firstWhere((mediaItem) => int.parse(mediaItem.id) == surah.id);

    // returns the index of the item in the playlist
    int indexOfSurah = _audioHandler.queue.value.indexOf(itemInPlaylist);

    _audioHandler.removeQueueItemAt(indexOfSurah);
  }

  void removeAll() {
    _audioHandler.updateQueue([]);
  }

  void dispose() {
    _audioHandler.customAction("dispose");
  }

  void stop() {
    _audioHandler.stop();
  }

  /**
   * GETTERS
   */

  List<Surah> get surahs => _surahs;
  List<Recitator> get recitators => _recitators;
}
