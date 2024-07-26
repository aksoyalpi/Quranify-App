import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:quran_fi/models/surahs_provider.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  //final _player = SurahsProvider();
  //final _player = AudioPlayer();
  final _player = SurahsProvider();

  // Function to create an audio source from a MediaItem
  UriAudioSource _createAudioSource(MediaItem item) {
    return ProgressiveAudioSource(Uri.parse(item.id));
  }

  // Broadcast the current playback state based on the received PlaybackEvent
  void _broadcastState(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        if (_player.isPlaying) MediaControl.pause else MediaControl.play,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.isPlaying,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentSurahIndex,
    ));
  }

  // Function to initialize the surahs and set up the audio player
  Future<void> initSurah({required MediaItem surah}) async {
    // Listen for playback events and broadcast the state
    _player.listenToPlaybackEvent(_broadcastState);

    // Create a list of audio sources from the provided songs
    final audioSource = _createAudioSource(surah);

    // Set the audio source of the audio player to the concatenation of the audio sources
    await _player.setAudioSource(audioSource);

    // Listen for processing state changes and skip to the next song when completed
    _player.makeWhenCompleted(skipToNext);
  }

  // Play function to start playback
  @override
  Future<void> play() => _player.play();

  // Pause function to pause playback
  @override
  Future<void> pause() => _player.pause();

  // Seek function to change the playback position
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  // Skip to a specific surah  and start playback
  Future<void> playSurah(int index) async {
    _player.currentSurahIndex = index;
    //_player.listenToPlaybackEvent(_broadcastState);

    // Set the audio source of the audio player to the concatenation of the audio sources
    await _player.setAudioSourceFromCurrentIndex();

    // Listen for processing state changes and skip to the next song when completed
    //_player.makeWhenCompleted(skipToNext);
    play();
  }

  // Skip to the next item in the queue
  @override
  Future<void> skipToNext() => _player.playNextSurah();

  // Skip to the previous item in the queue
  @override
  Future<void> skipToPrevious() => _player.playPreviousSurah();
}
