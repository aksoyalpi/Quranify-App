import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/components/neu_box.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/models/surahs_provider.dart';

class SurahPage extends StatelessWidget {
  const SurahPage({super.key});

  // conver duration into min:sec
  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    String formattedTime = "${duration.inMinutes}:$twoDigitSeconds";
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
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
                    IconButton(onPressed: () {}, icon: const Icon(Icons.menu))
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
                              Text(currentSurah.arabicTitle),
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
                        activeColor: Colors.green,
                        onChanged: (double double) {
                          // during when the user is sliding around
                        },
                        onChangeEnd: (double double) {
                          // sliding has finished, go to tha position in song duration
                          value.seek(Duration(seconds: double.toInt()));
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
                            onTap: value.playPreviousSurah,
                            child: const NeuBox(
                                child: Icon(Icons.skip_previous)))),

                    const SizedBox(
                      width: 20,
                    ),

                    // play pause
                    Expanded(
                        flex: 2,
                        child: GestureDetector(
                            onTap: value.pauseOrResume,
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
