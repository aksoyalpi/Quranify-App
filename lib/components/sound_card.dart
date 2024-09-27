import 'package:flutter/material.dart';
import 'package:quran_fi/consts/sounds.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';

class SoundCard extends StatelessWidget {
  SoundCard({super.key, required this.soundData});

  final MapEntry<String, IconData> soundData;

  final pageManager = getIt<PageManager>();

  void playSound() {
    pageManager.pause();

    pageManager.setSoundIndex(sounds.entries.indexed
        .firstWhere(
          (element) => element.$2.key == soundData.key,
        )
        .$1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // gets the index of the soundData
      onTap: playSound,
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.all(18),
          shape: OvalBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.secondary)),
          child: Icon(soundData.value),
        ),
      ),
    );
  }
}
