import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:quran_fi/components/neu_box.dart';
import 'package:quran_fi/components/sound_icon.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/notifiers/play_button_notifier.dart';
import 'package:quran_fi/page_manager.dart';

import '../services/service_locator.dart';

class SurahPage extends StatelessWidget {
  const SurahPage({super.key});

  // conver duration into min:sec
  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    String formattedTime = "${duration.inMinutes}:$twoDigitSeconds";
    return formattedTime;
  }

  void removeSurahFromPlaylist(Surah surah) {
    final pageManager = getIt<PageManager>();

    pageManager.remove(surah);
  }

  void showMenu(BuildContext context) {
    final pageManager = getIt<PageManager>();

    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ValueListenableBuilder(
            valueListenable: pageManager.currentRecitator,
            builder: (_, currentRecitator, __) {
              return Column(
                children: List.generate(
                  pageManager.recitators.length,
                  (index) {
                    final recitator = pageManager.recitators[index];
                    return RadioListTile(
                        title: Text(
                          recitator.name,
                        ),
                        subtitle: recitator.style != null
                            ? Text(recitator.style!,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12))
                            : null,
                        value: recitator.id,
                        groupValue: currentRecitator.id,
                        onChanged: (id) async {
                          if (id != null) {
                            await pageManager.changeRecitator(id);

                            pageManager.pause();
                            pageManager.play();
                            Navigator.pop(context);
                          }
                        });
                  },
                ),
              );
            }),
      ),
    );
  }

  void showPlaylist(BuildContext context) {
    final pageManager = getIt<PageManager>();

    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Column(
          children: List.generate(
            pageManager.playlist.length,
            (index) {
              final MediaItem surah = pageManager.playlist[index];
              return ListTile(
                leading: const Icon(Icons.drag_handle),
                title: Text(surah.title),
                subtitle: Text("Surah ${int.parse(surah.id)}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    )),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () =>
                      removeSurahFromPlaylist(Surah.fromMediaItem(surah)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    return Hero(
      tag: "audioplayer",
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // app bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // back button
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back)),

                    // title
                    const Text("S U R A H"),

                    Row(
                      children: [
                        // Playlist button
                        IconButton(
                            onPressed: (() => showPlaylist(context)),
                            icon: Icon(Icons.queue_music)),

                        // menu button
                        IconButton(
                            onPressed: () => showMenu(context),
                            icon: const Icon(Icons.menu))
                      ],
                    )
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),

                // album network
                NeuBox(
                    child: Column(
                  children: [
                    // image
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset("assets/images/quran.jpg")),

                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // surah and recitator name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ValueListenableBuilder(
                                  valueListenable:
                                      pageManager.currentSongTitleNotifier,
                                  builder: (_, surah, __) {
                                    return Text(
                                      surah,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    );
                                  }),
                              ValueListenableBuilder(
                                  valueListenable: pageManager.currentRecitator,
                                  builder: (_, recitator, __) =>
                                      Text(recitator.name)),
                            ],
                          ),

                          // heart Icon
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        ],
                      ),
                    )
                  ],
                )),

                const SizedBox(
                  height: 25,
                ),

                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // shuffle icon
                          ValueListenableBuilder(
                              valueListenable:
                                  pageManager.isShuffleModeEnabledNotifier,
                              builder: (_, isShuffleModeEnabled, __) {
                                return IconButton(
                                  icon: Icon(
                                    Icons.shuffle,
                                    color: isShuffleModeEnabled
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : null,
                                  ),
                                  onPressed: pageManager.shuffle,
                                );
                              }),

                          // nature sound icon
                          const SoundIcon(),

                          // repeat icon
                          const Icon(Icons.repeat),
                        ],
                      ),
                    ),

                    // song duration progress
                    ValueListenableBuilder(
                        valueListenable: pageManager.progressNotifier,
                        builder: (_, value, __) {
                          return ProgressBar(
                            thumbColor: Theme.of(context).colorScheme.onPrimary,
                            progressBarColor:
                                Theme.of(context).colorScheme.onPrimary,
                            progress: value.current,
                            buffered: value.buffered,
                            total: value.total,
                            onSeek: pageManager.seek,
                          );
                        }),
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),

                // playback controls
                Row(
                  children: [
                    // skip previous
                    Expanded(
                        child: ValueListenableBuilder(
                            valueListenable: pageManager.isFirstSongNotifier,
                            builder: (_, isFirst, __) {
                              return GestureDetector(
                                  onTap: /*(isFirst) ? null :*/
                                      pageManager.previous,
                                  child: const NeuBox(
                                      child: Icon(Icons.skip_previous)));
                            })),

                    const SizedBox(
                      width: 20,
                    ),

                    // play pause
                    Expanded(
                        flex: 2,
                        child: NeuBox(
                          child: ValueListenableBuilder(
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
                        )),

                    const SizedBox(
                      width: 20,
                    ),

                    // skip forward
                    Expanded(
                        child: ValueListenableBuilder(
                            valueListenable: pageManager.isLastSongNotifier,
                            builder: (_, isLast, __) {
                              return GestureDetector(
                                  onTap: /*isLast ? null :*/ pageManager.next,
                                  child: const NeuBox(
                                      child: Icon(Icons.skip_next)));
                            })),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
