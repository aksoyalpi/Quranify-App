import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_fi/components/modal_sheet_player.dart';
import 'package:quran_fi/components/recently_played_card.dart';
import 'package:quran_fi/components/surah_icon.dart';
import 'package:quran_fi/components/surah_tile.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/pages/surah_page.dart';
import 'package:quran_fi/services/service_locator.dart';

class SurahsPage extends StatefulWidget {
  const SurahsPage(
      {super.key, required this.surahs, required this.isFavoritesPage});

  final List<Surah> surahs;
  final bool isFavoritesPage;

  @override
  State<SurahsPage> createState() => _SurahsPageState();
}

class _SurahsPageState extends State<SurahsPage> {
  final pageManager = getIt<PageManager>();
  bool isListView = false;

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
    setState(() {});
  }

  void addSurahToPlaylist(BuildContext context, Surah surah) async {
    final pageManager = getIt<PageManager>();
    String text = "Added";
    SnackBarAction? action = SnackBarAction(
      label: "Undo",
      onPressed: () {},
    );

    bool alreadyInPlaylist = await pageManager.add(surah);

    if (alreadyInPlaylist) {
      text = "Surah already in playlist";
      action = null;
    }

    final snackBar = SnackBar(
      content: Text(text),
      action: action,
      elevation: 10,
      margin: const EdgeInsets.all(5),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          ListView(
            children: [
              // Recently Played
              recentlyPlayedBlock(),

              const SizedBox(
                height: 25,
              ),

              // TODO for next version
              /*soundsAndShuffle,
              const SizedBox(
                height: 25,
              ),*/

              Text(
                " All Surahs",
                style: GoogleFonts.bodoniModa(fontSize: 25),
              ),
              const SizedBox(height: 10),
              // All Surahs
              isListView ? allSurahsList() : allSurahsGrid()
            ],
          )
        else
          isListView ? allSurahsList() : allSurahsGrid(),

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
  Widget allSurahsGrid() => GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        padding: const EdgeInsets.only(bottom: 50),
        //childAspectRatio: 0.7,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),

        //crossAxisCount: 3,
        itemCount: widget.surahs.length,
        itemBuilder: (context, index) {
          // get individual surah
          final Surah surah = widget.surahs[index];
          // return list tile UI
          return InkWell(
            child: SurahIcon(surah: surah),
            onTap: () => goToSurah(surah),
          );
        },
      );

// Widget for List View of all Surahs
  Widget allSurahsList() => ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.surahs.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.surahs.length) {
            return const SizedBox(
              height: 100,
            );
          } else {
            // get individual surah
            final Surah surah = widget.surahs[index];
            // return list tile UI
            return SurahTile(
                surah: surah,
                onSlide: (context) => addSurahToPlaylist(context, surah),
                onTap: () => goToSurah(surah));
          }
        },
      );

  // Widget for recently played list
  Widget recentlyPlayedBlock() => Column(
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
      );

  Widget recentlyPlayedList() => ValueListenableBuilder(
      valueListenable: pageManager.recentlyPlayedNotifier,
      builder: (_, recentlyPlayed, __) => ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: recentlyPlayed.length,
            itemBuilder: (context, index) => InkWell(
                onTap: () => goToSurah(recentlyPlayed[index]),
                child: RecentlyPlayedCard(surah: recentlyPlayed[index])),
          ));
}
