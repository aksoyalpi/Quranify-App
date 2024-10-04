import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> surahsTargetsPage(
    {required GlobalKey surahIconKey,
    required GlobalKey searchIconKey,
    required GlobalKey changeViewKey}) {
  List<TargetFocus> targets = [];

  TargetFocus target({required GlobalKey keyTarget, required Widget child}) =>
      TargetFocus(
          keyTarget: keyTarget,
          alignSkip: Alignment.topLeft,
          radius: 10,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) =>
                  Container(alignment: Alignment.center, child: child),
            )
          ]);

  targets.add(target(
    keyTarget: surahIconKey,
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Tap to listen to Surah",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("Swipe up for more action",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("Hold to choose more surahs at once",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
      ],
    ),
  ));

  targets.add(target(
      keyTarget: searchIconKey,
      child: const Text(
        "Search for Surah",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      )));

  targets.add(target(
      keyTarget: changeViewKey,
      child: const Text("Tap to change layout",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))));

  // targets.add(target(keyTarget: viewChangeKey, ))

  return targets;
}
