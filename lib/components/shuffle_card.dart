import 'package:flutter/material.dart';

class ShuffleCard extends StatelessWidget {
  const ShuffleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {},
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    BorderSide(color: Theme.of(context).colorScheme.secondary)),
            color: Theme.of(context).colorScheme.surface,
            shadowColor: Theme.of(context).colorScheme.primary,
            margin: const EdgeInsets.all(10),
            elevation: 5,
            child: const Icon(
              Icons.shuffle,
              size: 100,
            )),
      ),
    );
  }
}
