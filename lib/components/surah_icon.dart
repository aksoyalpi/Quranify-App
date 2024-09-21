import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';

import '../models/surah.dart';

class SurahIcon extends StatelessWidget {
  const SurahIcon({super.key, required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    final innerContent = Center(
        child: Text(
      surah.id.toString(),
      style: GoogleFonts.bodoniModa(fontSize: 20),
    ));

    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: pageManager.favoritesNotifier,
          builder: (_, favorites, __) {
            if (favorites.contains(surah)) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 75,
                    width: 75,
                    child: Image.asset(
                      "assets/icons/heart.png",
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  innerContent,
                ],
              );
            } else {
              return ClipOval(
                  child: Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary)),
                      child: innerContent));
            }
          },
        ),
        Text(surah.arabicTitle),
        Text(surah.title)
      ],
    );
  }
}
