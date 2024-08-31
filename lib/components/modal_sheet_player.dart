import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quran_fi/notifiers/play_button_notifier.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';

class LittleAudioPlayer extends StatefulWidget {
  const LittleAudioPlayer({super.key});

  @override
  State<LittleAudioPlayer> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LittleAudioPlayer> {
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.secondary),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // picture
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            "assets/images/quran.jpg",
                            fit: BoxFit.cover,
                          )),
                    ),

                    const SizedBox(width: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Surah title
                        ValueListenableBuilder(
                          valueListenable: pageManager.currentSongTitleNotifier,
                          builder: (_, surah, __) => Text(surah),
                        ),

                        // Recitator
                        ValueListenableBuilder(
                          valueListenable: pageManager.currentRecitator,
                          builder: (_, recitator, __) => Text(recitator.name),
                        ),
                      ],
                    ),
                  ],
                ),

                // play pause Button
                ValueListenableBuilder(
                    valueListenable: pageManager.playButtonNotifier,
                    builder: (_, value, __) {
                      switch (value) {
                        case ButtonState.loading:
                          return const Center(
                              child: CircularProgressIndicator());
                        case ButtonState.paused:
                          return IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: pageManager.play,
                          );
                        case ButtonState.playing:
                          return IconButton(
                              onPressed: pageManager.pause,
                              icon: const Icon(Icons.pause));
                      }
                    }),
              ],
            ),

            const SizedBox(height: 15),

            // song duration progress
            ValueListenableBuilder(
                valueListenable: pageManager.progressNotifier,
                builder: (_, value, __) {
                  return LinearProgressIndicator(
                    value: value.current.inSeconds / value.total.inSeconds,
                    color: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,

                    /*thumbColor: Theme.of(context).colorScheme.onPrimary,
                    progressBarColor: Theme.of(context).colorScheme.onPrimary,
                    progress: value.current,
                    buffered: value.buffered,
                    total: value.total,
                    onSeek: pageManager.seek,*/
                  );
                }),
          ],
        ),
      ),
    );
  }
}
