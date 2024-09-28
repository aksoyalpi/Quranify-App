import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_fi/helper_functions.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';

import '../models/surah.dart';

class SurahIcon extends StatefulWidget {
  const SurahIcon({super.key, required this.surah});

  final Surah surah;

  @override
  State<SurahIcon> createState() => _SurahIconState();
}

class _SurahIconState extends State<SurahIcon> {
  final pageManager = getIt<PageManager>();
  int currentPage = 0;
  final pageController =
      PageController(initialPage: 0, keepPage: false, viewportFraction: 0.6);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Column(
          children: [
            ValueListenableBuilder(
              valueListenable: pageManager.favoritesNotifier,
              builder: (_, favorites, __) {
                bool isFavorite = favorites.contains(widget.surah);
                return ClipOval(
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 85,
                        width: 85,
                        decoration: BoxDecoration(
                            color: currentPage == 0 ? null : Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isFavorite
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.primary)),
                        child: PageView(
                            padEnds: true,
                            controller: pageController,
                            onPageChanged: (value) =>
                                setState(() => currentPage = value),
                            scrollDirection: Axis.vertical,
                            children: [
                              innerContent(),
                              addToPlaylistWidget(widget.surah)
                            ])));
              },
            ),
            Text(widget.surah.arabicTitle),
            Text(widget.surah.title)
          ],
        ),
      ],
    );
  }

  Widget innerContent() => Center(
          child: Text(
        widget.surah.id.toString(),
        style: GoogleFonts.bodoniModa(fontSize: 20),
      ));

  Widget addToPlaylistWidget(Surah surah) => Center(
        child: IconButton(
          icon: const Icon(Icons.playlist_add),
          onPressed: () {
            addSurahToPlaylist(context, surah);
            setState(() {
              currentPage = 0;
            });
            pageController.jumpToPage(0);
          },
        ),
      );
}
