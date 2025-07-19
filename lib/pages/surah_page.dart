import 'dart:ui';

import 'package:animated_background/animated_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:quran_fi/components/neu_box.dart';
import 'package:quran_fi/components/sleep_timer_dialog.dart';
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

class _SurahPageState extends State<SurahPage> with TickerProviderStateMixin {
  final pageManager = getIt<PageManager>();

  // conver duration into min:sec
  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "${duration.inMinutes}:$twoDigitSeconds";
  }

  void removeSurahFromPlaylist(Surah surah) {
    pageManager.remove(surah);
  }

  void playSurah(Surah surah) {
    final pageManager = getIt<PageManager>();
    pageManager.playSurah(surah);
  }

  void _handleSleepTimer(context) {
    showDialog(
      context: context,
      builder: (context) => const SleepTimerDialog(),
    );
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
                            if (context.mounted) Navigator.pop(context);
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
    showModalBottomSheet(
        context: context, builder: (context) => playlistWidget());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dy > 5) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Icons.keyboard_arrow_down)),
          backgroundColor: Colors.transparent,
          bottomOpacity: 0,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: (() => showPlaylist(context)),
                icon: const Icon(Icons.queue_music)),
            IconButton(
                onPressed: () => showMenu(context),
                icon: const Icon(Icons.person)),
            IconButton(
                onPressed: () => _handleSleepTimer(context),
                icon: ValueListenableBuilder(
                  valueListenable: pageManager.sleepTimer,
                  builder: (_, time, __) {
                    if (time <= 0) {
                      return const Icon(Icons.timer);
                    } else {
                      return Text(time.toString());
                    }
                  },
                ))
          ],
        ),
        body: ValueListenableBuilder(
            valueListenable: pageManager.playButtonNotifier,
            builder: (_, value, __) => AnimatedBackground(
                  behaviour: RandomParticleBehaviour(
                    options: ParticleOptions(
                        spawnMaxRadius: 50,
                        spawnMinSpeed: value == ButtonState.paused ||
                                value == ButtonState.loading
                            ? 0
                            : 25,
                        particleCount: 60,
                        spawnMaxSpeed: value == ButtonState.loading ||
                                value == ButtonState.paused
                            ? 0
                            : 50,
                        minOpacity: 0.1,
                        maxOpacity: 1,
                        opacityChangeRate: 0.25,
                        spawnOpacity: 0,
                        baseColor: Theme.of(context).colorScheme.primary),
                  ),
                  vsync: this,
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.1),
                        child: surahPage(),
                      )),
                )),
      ),
    );
  }

  Widget playlistWidget() => Stack(
        children: [
          ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 75),
            itemCount: pageManager.playlist.length,
            itemBuilder: (context, index) {
              final MediaItem surah = pageManager.playlist[index];
              // variable to ask if surah is the surah that is currently playing
              final bool isPlaying;
              if (pageManager.currentSongTitleNotifier.value == surah.title) {
                isPlaying = true;
              } else {
                isPlaying = false;
              }

              return ListTile(
                key: Key(surah.id),
                iconColor:
                    isPlaying ? Theme.of(context).colorScheme.onPrimary : null,
                leading: const Icon(Icons.drag_handle),
                title: Text(
                  surah.title,
                ),
                subtitle: Text(surah.extras!["arabicTitle"],
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () =>
                      removeSurahFromPlaylist(Surah.fromMediaItem(surah)),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) async {
              pageManager.move(oldIndex, newIndex);
            },
          ),

          // Deleta all Surahs from playlist button
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                await pageManager.removeAll();
                if (context.mounted) {
                  Navigator.popUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    (route) => route.isFirst,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  foregroundColor: Theme.of(context).colorScheme.surface),
              child: const Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 10),
                  Text("Delete All"),
                ],
              ),
            ),
          )
        ],
      );

  Widget surahPage() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // album network
              NeuBox(
                  child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // image
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                            "assets/images/quran.jpg" /*"assets/animations/rain_animation.gif"*/)),

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
                                          setState(
                                            () {},
                                          );
                                        },
                                        icon: Icon(iconData));
                                  });
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )),

              const SizedBox(
                height: 25,
              ),

              Column(
                children: [
                  const SoundIcon(),

                  const SizedBox(
                    height: 15,
                  ),

                  // song duration progress
                  ValueListenableBuilder(
                      valueListenable: pageManager.progressNotifier,
                      builder: (_, value, __) {
                        //print("total: ${value.total}");
                        //print("Position: ${value.current}");
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // shuffle icon
                  ValueListenableBuilder(
                      valueListenable: pageManager.isShuffleModeEnabledNotifier,
                      builder: (_, isShuffleModeEnabled, __) {
                        return IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: isShuffleModeEnabled
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                          onPressed: pageManager.shuffle,
                        );
                      }),

                  // skip previous
                  GestureDetector(
                      onTap: /*(isFirst) ? null :*/
                          pageManager.previous,
                      child: const Icon(Icons.skip_previous)),

                  // play pause
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

                  // skip forward
                  GestureDetector(
                      onTap: /*isLast ? null :*/ pageManager.next,
                      child: const Icon(Icons.skip_next)),

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
                          iconColor = Theme.of(context).colorScheme.onPrimary;
                          break;

                        case RepeatModeState.one:
                          iconData = Icons.repeat_one_outlined;
                          iconColor = Theme.of(context).colorScheme.onPrimary;
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

              const SizedBox(
                height: 25,
              )
            ],
          ),
        ),
      );
}
