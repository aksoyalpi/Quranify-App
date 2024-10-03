import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_fi/components/modal_sheet_player.dart';
import 'package:quran_fi/components/recently_played_card.dart';
import 'package:quran_fi/components/surah_icon.dart';
import 'package:quran_fi/components/surah_tile.dart';
import 'package:quran_fi/helper_functions.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/pages/surah_page.dart';
import 'package:quran_fi/services/service_locator.dart';

class SurahsPage extends StatefulWidget {
  const SurahsPage({
    super.key,
    required this.surahs,
    required this.isFavoritesPage,
    required this.isListView,
  });

  final List<Surah> surahs;
  final bool isFavoritesPage;
  final bool isListView;

  @override
  State<SurahsPage> createState() => _SurahsPageState();
}

class _SurahsPageState extends State<SurahsPage> {
  final pageManager = getIt<PageManager>();

  // go to surah with index surahIndex
  void goToSurah(Surah surah) async {
    // update current surah index
    final pageManager = getIt<PageManager>();
    pageManager.playSurah(surah);

    // navigate to surah page
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SurahPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
                position: animation.drive(
                    Tween(begin: const Offset(0, 1), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.ease))),
                child: child),
      ),
    );
    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // sound icons and shuffle mode
    // final soundsAndShuffle = SizedBox(
    //   height: 200,
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     mainAxisSize: MainAxisSize.max,
    //     children: [
    //       // Nature sound Icons
    //       Expanded(
    //         child: Column(
    //           mainAxisSize: MainAxisSize.max,
    //           children: [
    //             Expanded(
    //               child: Row(
    //                 children: [
    //                   Expanded(
    //                       child: SoundCard(
    //                     soundData: sounds.entries.elementAt(1),
    //                   )),
    //                   Expanded(
    //                       child: SoundCard(
    //                     soundData: sounds.entries.elementAt(2),
    //                   ))
    //                 ],
    //               ),
    //             ),
    //             Expanded(
    //               child: Row(
    //                 children: [
    //                   Expanded(
    //                       child: SoundCard(
    //                     soundData: sounds.entries.elementAt(3),
    //                   )),
    //                   Expanded(
    //                       child: SoundCard(
    //                     soundData: sounds.entries.elementAt(4),
    //                   ))
    //                 ],
    //               ),
    //             )
    //           ],
    //         ),
    //       ),

    //       // Shuffle Card
    //       const Expanded(child: SizedBox(height: 200, child: ShuffleCard())),
    //     ],
    //   ),
    // );

    return Stack(
      children: [
        if (!widget.isFavoritesPage)
          CustomScrollView(
            slivers: [
              // Recently Played
              recentlyPlayedBlock(),

              const SliverToBoxAdapter(
                child: const SizedBox(
                  height: 25,
                ),
              ),

              // TODO for next version
              /*soundsAndShuffle,
              const SizedBox(
                height: 25,
              ),*/

              SliverToBoxAdapter(
                child: Text(
                  " All Surahs",
                  style: GoogleFonts.bodoniModa(fontSize: 25),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              // All Surahs
              widget.isListView ? allSurahsList() : allSurahsGrid(),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                ),
              )
            ],
          )
        else
          CustomScrollView(slivers: [
            widget.isListView ? allSurahsList() : allSurahsGrid(),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
              ),
            )
          ]),

        // little AudioPlayer
        ValueListenableBuilder(
          valueListenable: pageManager.currentSongTitleNotifier,
          builder: (_, surah, __) {
            if (surah == "") {
              return const SizedBox(
                width: 0,
                height: 0,
              );
            } else {
              return const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                    child: LittleAudioPlayer(),
                  ));
            }
          },
        ),
      ],
    );
  }

  // Widget for GridView of all Surahs
  Widget allSurahsGrid() => SliverGrid.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),

        //crossAxisCount: 3,
        itemCount: widget.surahs.length,
        itemBuilder: (context, index) {
          // get individual surah
          final Surah surah = widget.surahs[index];
          // return list tile UI
          return ValueListenableBuilder(
              valueListenable: pageManager.choosedSurahs,
              builder: (_, choosedSurahs, __) => ValueListenableBuilder(
                  valueListenable: pageManager.isChooseMode,
                  builder: (_, isChooseMode, __) {
                    bool isChosen = choosedSurahs.contains(surah);
                    return GestureDetector(
                      onLongPress: () {
                        pageManager.switchChooseMode();
                        pageManager.chooseSurah(surah);
                      },
                      // if page is in choose mode the user should trigger the method to choose surahs, else he should go to the surah page
                      onTap: () => isChooseMode
                          ? pageManager.chooseSurah(surah)
                          : goToSurah(surah),
                      child: SurahIcon(
                        surah: surah,
                        isChooseMode: isChooseMode,
                        isChosen: isChosen,
                      ),
                    );
                  }));
        },
      );

// Widget for List View of all Surahs
  Widget allSurahsList() => SliverList.builder(
        //shrinkWrap: true,
        itemCount: widget.surahs.length,
        itemBuilder: (context, index) {
          // get individual surah
          final Surah surah = widget.surahs[index];
          // return list tile UI
          return GestureDetector(
            onLongPress: () {
              pageManager.switchChooseMode();
              pageManager.chooseSurah(surah);
            },
            child: ValueListenableBuilder(
                valueListenable: pageManager.isChooseMode,
                builder: (_, isChooseMode, __) {
                  return ValueListenableBuilder(
                      valueListenable: pageManager.choosedSurahs,
                      builder: (_, chosenSurahs, __) {
                        final isChosen = chosenSurahs.contains(surah);
                        return SurahTile(
                          surah: surah,
                          onSlide: (context) =>
                              addSurahToPlaylist(context, surah),
                          onTap: () => isChooseMode
                              ? pageManager.chooseSurah(surah)
                              : goToSurah(surah),
                          isChosen: isChosen,
                        );
                      });
                }),
          );
        },
      );

  // Widget for recently played list
  Widget recentlyPlayedBlock() => SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pageManager.recentlyPlayedNotifier.value.isNotEmpty)
              Text(
                " Recently Played",
                style: GoogleFonts.bodoniModa(fontSize: 25),
              ),

            // recently played Surahs
            SizedBox(height: 120, child: recentlyPlayedList())
          ],
        ),
      );

  Widget recentlyPlayedList() => ValueListenableBuilder(
      valueListenable: pageManager.recentlyPlayedNotifier,
      builder: (_, recentlyPlayed, __) => ListView.builder(
            //shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: recentlyPlayed.length,
            itemBuilder: (context, index) => InkWell(
                onTap: () => goToSurah(recentlyPlayed[index]),
                child: RecentlyPlayedCard(surah: recentlyPlayed[index])),
          ));
}
