import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_fi/consts/sounds.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mycompany.myapp.audio',
        androidNotificationChannelName: 'Quran',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: "mipmap/icon_removebg"),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _soundPlayer = AudioPlayer();
  Timer? _sleepTimer;

  bool isSoundOn = false;

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _listenForSequenceStateChanges();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSurahIndexChanges();
  }

  int getCurrentIndex() {
    return _player.currentIndex ?? 0;
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSources([]);
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          //MediaControl.stop,
          MediaControl.skipToNext,
        ],
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        // speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices.indexOf(index);
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(Uri.parse(mediaItem.extras!["url"] as String),
        tag: mediaItem);
  }

  void _listenForCurrentSurahIndexChanges() {
    _player.currentIndexStream.listen((index) async {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices.indexOf(index);
      }
      mediaItem.add(playlist[index]);
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final audioSources = mediaItems.map(_createAudioSource);
    _player.addAudioSources(audioSources.toList());
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    _player.addAudioSource(_createAudioSource(mediaItem));
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    _player.insertAudioSource(index, _createAudioSource(mediaItem));
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    _player.removeAudioSourceAt(index);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    _player.clearAudioSources();
    await addQueueItems(queue);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      default:
        _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices.indexOf(index);
    }
    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> play() async {
    _player.play();
    if (isSoundOn) {
      _soundPlayer.play();
    }
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> pause() async {
    _player.pause();
    _soundPlayer.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    } else if (name == "removeAll") {
      // manage Just Audio
      _player.clearAudioSources();
      queue.value = [];
    } else if (name == "setVolume") {
      await _player.setVolume(extras!["volume"]);
    } else if (name == "setSoundIndex") {
      _soundPlayer.pause();

      if (extras!["index"] != 0) {
        await _soundPlayer.setAudioSource(AudioSource.asset(
            "assets/audio/${sounds.keys.elementAt(extras["index"])}.mp3"));
        _soundPlayer.play();

        await _soundPlayer.setLoopMode(LoopMode.one);

        isSoundOn = true;
      } else {
        isSoundOn = false;
      }
    } else if (name == "setSoundVolume") {
      _soundPlayer.setVolume(extras!["volume"]);
    } else if (name == "clear") {
      _player.clearAudioSources();
      queue.value.clear();
    } else if (name == "move") {
      if (extras != null &&
          extras.containsKey("oldIndex") &&
          extras.containsKey("newIndex")) {
        // moves AudioSource from oldIndex to NewIndex
        _player.moveAudioSource(extras["oldIndex"], extras["newIndex"]);
      }
    } else if (name == "setSleepTimer") {
      _sleepTimer?.cancel();
      if (extras != null &&
          extras.containsKey("minutes") &&
          extras["minutes"] > 0) {
        _sleepTimer = Timer(
          Duration(minutes: extras["minutes"]),
          () {
            pause();
          },
        );
      }
    }
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /* GETTER */
  int get queueLength => queue.value.length;
  int get currentPlaylistIndex =>
      _player.currentIndex ?? queue.value.length - 1;
}
