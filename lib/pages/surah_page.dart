import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:quran_fi/components/neu_box.dart';
import 'package:quran_fi/components/sound_icon.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/notifiers/play_button_notifier.dart';
import 'package:quran_fi/notifiers/repeat_mode_notifer.dart';
import 'package:quran_fi/page_manager.dart';

import '../services/service_locator.dart';

class SurahPage extends StatefulWidget {
  const SurahPage({super.key});

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
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

  void playSurah(Surah surah) {
    final pageManager = getIt<PageManager>();
    pageManager.playSurah(surah);
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

    //final playlist =

    showModalBottomSheet(
        context: context,
        builder: (context) => ReorderableListView(
              children: List.generate(
                pageManager.playlist.length,
                (index) {
                  final MediaItem surah = pageManager.playlist[index];
                  // variable to ask if surah is the surah that is currently playing
                  final isPlaying;
                  if (pageManager.currentSongTitleNotifier.value ==
                      surah.title) {
                    isPlaying = true;
                  } else {
                    isPlaying = false;
                  }

                  return ListTile(
                    key: Key(surah.id),
                    iconColor: Theme.of(context).colorScheme.onPrimary,
                    tileColor: isPlaying
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                    leading: const Icon(Icons.drag_handle),
                    title: Text(
                      surah.title,
                    ),
                    subtitle: Text("Surah ${int.parse(surah.id)}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    onTap: () {
                      playSurah(Surah.fromMediaItem(surah));
                      Navigator.pop(context);
                    },
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed: () =>
                          removeSurahFromPlaylist(Surah.fromMediaItem(surah)),
                    ),
                  );
                },
              ),
              onReorder: (oldIndex, newIndex) async {
                final currentSurahTitle =
                    pageManager.currentSongTitleNotifier.value;
                print("1. current $currentSurahTitle");
                final surahThatIsDragged = pageManager.playlist[oldIndex].title;
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final surah =
                    Surah.fromMediaItem(pageManager.playlist[oldIndex]);
                pageManager.remove(surah);
                await pageManager.add(surah, index: newIndex);

                //check if tile that is reordered is current playing surah
                if (currentSurahTitle == surahThatIsDragged) {
                  pageManager.playSurah(surah);
                }
              },
            ));
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

                          ValueListenableBuilder(
                            valueListenable: pageManager.favoritesNotifier,
                            builder: (__, favorites, _) {
                              return ValueListenableBuilder(
                                  valueListenable:
                                      pageManager.currentSongTitleNotifier,
                                  builder: (__, surahTitle, _) {
                                    bool isFavorite = false;

                                    for (var surah in favorites) {
                                      if (surah.title == surahTitle) {
                                        isFavorite = true;
                                      }
                                    }

                                    IconData iconData = isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border;

                                    return IconButton(
                                        onPressed: () {
                                          final surah =
                                              pageManager.surahs.firstWhere(
                                            (element) =>
                                                element.title == surahTitle,
                                          );
                                          if (isFavorite) {
                                            favorites.remove(surah);
                                          } else {
                                            favorites.add(surah);
                                          }
                                          pageManager
                                              .changeFavorites(favorites);
                                        },
                                        icon: Icon(iconData));
                                  });
                            },
                          ),
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
                          ValueListenableBuilder(
                            valueListenable: pageManager.repeatModeNotifier,
                            builder: (_, repeatMode, __) {
                              IconData iconData;
                              Color? iconColor;
                              switch (repeatMode) {
                                case RepeatModeState.none:
                                  iconData = Icons.repeat;
                                  break;
                                case RepeatModeState.all:
                                  iconData = Icons.repeat_outlined;
                                  iconColor =
                                      Theme.of(context).colorScheme.onPrimary;
                                  break;

                                case RepeatModeState.one:
                                  iconData = Icons.repeat_one_outlined;
                                  iconColor =
                                      Theme.of(context).colorScheme.onPrimary;
                                  break;
                              }

                              return IconButton(
                                  onPressed: pageManager.repeat,
                                  icon: Icon(
                                    iconData,
                                    color: iconColor,
                                  ));
                            },
                          )
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
