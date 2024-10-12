import 'package:flutter/material.dart';
import 'package:quran_fi/components/neu_box.dart';
import 'package:quran_fi/notifiers/play_button_notifier.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/pages/surah_page.dart';
import 'package:quran_fi/services/service_locator.dart';

class LittleAudioPlayer extends StatefulWidget {
  const LittleAudioPlayer({super.key});

  @override
  State<LittleAudioPlayer> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LittleAudioPlayer> {
  bool _hasSwiped = false;

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    return GestureDetector(
      onPanStart: (details) => _hasSwiped = false,
      onPanUpdate: (details) {
        if (!_hasSwiped) {
          if (details.delta.dx > 5) {
            pageManager.previous();
          } else if (details.delta.dx < -5) {
            pageManager.next();
          }
          _hasSwiped = true;
        }
      },
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SurahPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                        position: animation.drive(
                            Tween(begin: const Offset(0, 1), end: Offset.zero)
                                .chain(CurveTween(curve: Curves.easeInOut))),
                        child: child),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: NeuBox(
          sigmaX: 3,
          sigmaY: 3,
          border: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // picture
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
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
                              valueListenable:
                                  pageManager.currentSongTitleNotifier,
                              builder: (_, surah, __) => Text(
                                surah,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),

                            // Recitator
                            ValueListenableBuilder(
                              valueListenable: pageManager.currentRecitator,
                              builder: (_, recitator, __) => Text(
                                  recitator.name,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
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
              ),

              // song duration progress
              ValueListenableBuilder(
                  valueListenable: pageManager.progressNotifier,
                  builder: (_, value, __) {
                    final double currentPos;

                    if (value.total.inSeconds == 0) {
                      currentPos = 0;
                    } else {
                      currentPos =
                          value.current.inSeconds / value.total.inSeconds;
                    }

                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8)),
                      child: LinearProgressIndicator(
                          value: currentPos,
                          color: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          minHeight: 5),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
