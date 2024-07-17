import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quran_fi/models/surahs_provider.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = SurahsProvider();

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  //Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);
  //Future<void> skipToQueueItem(int i) => _player.seek(Duration.zero, index: i);

  // All options shown:
  /*playbackState.add(PlaybackState(
      // Which buttons should appear in the notification now
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      // Which other actions should be enabled in the notification
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      // Which controls to show in Android's compact view.
      androidCompactActionIndices: const [0, 1, 3],
      // Whether audio is ready, buffering, ...
      processingState: AudioProcessingState.ready,
      // Whether audio is playing
      playing: true,
      // The current position as of this update. You should not broadcast
      // position changes continuously because listeners will be able to
      // project the current position after any elapsed time based on the
      // current speed and whether audio is playing and ready. Instead, only
      // broadcast position updates when they are different from expected (e.g.
      // buffering, or seeking).
      updatePosition: Duration(milliseconds: 54321),
      // The current buffered position as of this update
      bufferedPosition: Duration(milliseconds: 65432),
      // The current speed
      speed: 1.0,
      // The current queue position
      queueIndex: 0,
    ));*/
}
