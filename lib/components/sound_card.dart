import 'package:flutter/material.dart';

class SoundCard extends StatelessWidget {
  const SoundCard({super.key, required this.soundData});

  final MapEntry<String, IconData> soundData;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        margin: const EdgeInsets.all(18),
        shape: OvalBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.primary)),
        child: Icon(soundData.value),
      ),
    );
  }
}
