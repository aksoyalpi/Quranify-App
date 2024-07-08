import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/components/neu_box.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/models/surahs_provider.dart';

class SurahPage extends StatelessWidget {
  const SurahPage({super.key});

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
                        icon: Icon(Icons.arrow_back)),

                    // title
                    Text("S U R A H"),

                    // menu button
                    IconButton(onPressed: () {}, icon: Icon(Icons.menu))
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
                        child: Image.asset("../assets/images/quran.jpg")),

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
                              Text(currentSurah.recitator),
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
                    const Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // start time
                          Text("0:00"),

                          // shuffle icon
                          Icon(Icons.shuffle),

                          // repeat icon
                          Icon(Icons.repeat),

                          // end time
                          Text("0:00")
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
                          max: 100,
                          value: 50,
                          activeColor: Colors.green,
                          onChanged: (value) {}),
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
                            onTap: () {},
                            child: NeuBox(child: Icon(Icons.skip_previous)))),

                    const SizedBox(
                      width: 20,
                    ),

                    // play pause
                    Expanded(
                        flex: 2,
                        child: GestureDetector(
                            onTap: () {},
                            child: NeuBox(child: Icon(Icons.play_arrow)))),

                    const SizedBox(
                      width: 20,
                    ),

                    // skip forward
                    Expanded(
                        child: GestureDetector(
                            onTap: () {},
                            child: NeuBox(child: Icon(Icons.skip_next)))),
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
