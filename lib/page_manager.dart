import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_fi/consts/recitations.dart';
import 'package:quran_fi/consts/surahs.dart';
import 'package:quran_fi/models/recitator.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/services/api.dart';
import 'package:quran_fi/services/shared_prefs.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'services/service_locator.dart';

class PageManager {
  final _audioHandler = getIt<AudioHandler>();
  final _soundPlayer = AudioPlayer();
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final currentRecitator =
      ValueNotifier<Recitator>(Recitator.fromJson(recitations[0]));
  final currentSoundIndex = ValueNotifier<int>(0);
  final quranVolume = ValueNotifier<double>(1);
  final soundVolume = ValueNotifier<double>(1);

  get playlist => _audioHandler.queue.value;

  // all surahs
  final List<Surah> _surahs = List.generate(
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

  Future<void> changeRecitator(int id) async {
    currentRecitator.value = _recitators.firstWhere(
      (element) => element.id == id,
    );
    stop();
    // TODO: change current playing song
    //await _loadNewPlaylist();
    play();
  }

  Future<void> _initDefaultRecitator() async {
    final int? defaultRecitatorId = await SharedPrefs.getDefaultRecitator();
    if (defaultRecitatorId == null) {
      currentRecitator.value = recitators[0];
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
      //await _loadNewPlaylist();
      play();
    }
  }

  void setSoundIndex(int index) async {
    _soundPlayer.pause();
    currentSoundIndex.value = index;
    _soundPlayer.pause();
    if (currentSoundIndex.value != 0) {
      await _soundPlayer.setAudioSource(AudioSource.asset(
          "assets/audio/${_sounds.keys.elementAt(currentSoundIndex.value)}.mp3"));
      _soundPlayer.play();
    }
  }

  void setSoundVolume(double volume) {
    _soundPlayer.setVolume(volume);
    soundVolume.value = volume;
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
    _audioHandler.mediaItem.listen((MediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
          current: oldState.current,
          buffered: oldState.buffered,
          total: MediaItem?.duration ?? Duration.zero);
    });
  }

  void _listenToChangesInSurah() {
    _audioHandler.mediaItem.listen((mediaItem) {
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
    _soundPlayer.setLoopMode(LoopMode.all);
    await _initDefaultRecitator();
    //await _loadPlaylist();
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
    if (currentSoundIndex.value != 0) _soundPlayer.play();
  }

  void pause() {
    _audioHandler.pause();
    if (currentSoundIndex.value != 0) _soundPlayer.pause();
  }

  void seek(Duration position) => _audioHandler.seek(position);
  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();
  void repeat() {
    // TODO
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
  /// returns if the surah was already in the playlist
  Future<bool> add(Surah surah,
      {bool placeAtCurrentPosition = false, index = -1}) async {
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
      int currentIndex =
          _audioHandler.queue.value.indexOf(_audioHandler.mediaItem.value!);

      await _audioHandler.insertQueueItem(currentIndex + 1, item);
    } else if (index == -1) {
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
  Map<String, IconData> get sounds => _sounds;
  List<Recitator> get recitators => _recitators;
}
