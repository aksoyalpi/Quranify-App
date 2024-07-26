import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/components/neu_box.dart';
import 'package:quran_fi/components/sound_icon.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/models/surahs_provider.dart';
import 'package:quran_fi/services/audio_handler.dart';

class SurahPage extends StatelessWidget {
  const SurahPage({super.key, required this.audioHandler});

  final MyAudioHandler audioHandler;

  // conver duration into min:sec
  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    String formattedTime = "${duration.inMinutes}:$twoDigitSeconds";
    return formattedTime;
  }

  void showMenu(BuildContext context, SurahsProvider value) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Column(
          children: List.generate(
            value.recitators.length,
            (index) {
              final recitator = value.recitators[index];
              return RadioListTile(
                  title: Text(
                    recitator.name,
                  ),
                  subtitle: recitator.style != null
                      ? Text(recitator.style!,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12))
                      : null,
                  value: value.recitators[index].id,
                  groupValue: value.currentRecitator.id,
                  onChanged: (id) {
                    if (id != null) {
                      value.currentRecitator = value.recitators.firstWhere(
                        (element) => element.id == id,
                      );

                      value.pause();
                      value.play();
                      Navigator.pop(context);
                    }
                  });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool pausedBeforeSliding = false;

    return Consumer<SurahsProvider>(builder: (context, value, child) {
      // get surahs
      final surahs = value.surahs;

      // get current surah index
      final Surah currentSurah = surahs[value.currentSurahIndex ?? 0];

      // return UI
      return Scaffold(
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

                    // menu button
                    IconButton(
                        onPressed: () => showMenu(context, value),
                        icon: const Icon(Icons.menu))
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
                              Text(
                                currentSurah.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(value.currentRecitator.name),
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

                // song duration progress
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // start time
                          Text(formatTime(value.currentDuration)),

                          // shuffle icon
                          const Icon(Icons.shuffle),

                          // nature sound icon
                          const SoundIcon(),

                          // repeat icon
                          const Icon(Icons.repeat),

                          // end time
                          Text(formatTime(value.totalDuration))
                        ],
                      ),
                    ),

                    // song duration progress
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 0)),
                      child: Slider(
                        min: 0,
                        max: value.totalDuration.inSeconds.toDouble(),
                        value: value.currentDuration.inSeconds.toDouble(),
                        inactiveColor: Theme.of(context).colorScheme.secondary,
                        activeColor: Theme.of(context).colorScheme.onPrimary,
                        onChanged: (double double) {
                          // during when the user is sliding around
                          if (value.isPlaying) {
                            pausedBeforeSliding = false;
                            audioHandler.pause();
                          } else {
                            pausedBeforeSliding = true;
                          }
                          audioHandler.seek(Duration(seconds: double.toInt()));
                        },
                        onChangeEnd: (double double) {
                          // sliding has finished, go to tha position in song duration
                          audioHandler.seek(Duration(seconds: double.toInt()));
                          if (!pausedBeforeSliding) {
                            audioHandler.play();
                          }
                        },
                      ),
                    ),
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
                        child: GestureDetector(
                            onTap: () => audioHandler.skipToPrevious,
                            child: const NeuBox(
                                child: Icon(Icons.skip_previous)))),

                    const SizedBox(
                      width: 20,
                    ),

                    // play pause
                    Expanded(
                        flex: 2,
                        child: GestureDetector(
                            onTap: () => value.isPlaying
                                ? audioHandler.pause()
                                : audioHandler.play(),
                            child: NeuBox(
                                child: Icon(value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow)))),

                    const SizedBox(
                      width: 20,
                    ),

                    // skip forward
                    Expanded(
                        child: GestureDetector(
                            onTap: value.playNextSurah,
                            child: const NeuBox(child: Icon(Icons.skip_next)))),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
