import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/components/modal_sheet_player.dart';
import 'package:quran_fi/components/recently_played_card.dart';
import 'package:quran_fi/components/surah_icon.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/pages/settings_page.dart';
import 'package:quran_fi/pages/surah_page.dart';
import 'package:quran_fi/services/service_locator.dart';
import 'package:quran_fi/themes/theme_provider.dart';

Future<void> main() async {
  await setupServiceLocator();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: const MyApp(),
  ));

  // Set preferred orientations for the app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // TODO: should only be called the first time
  //await SharedPrefs.initialize();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getIt<PageManager>().init();
    //Provider.of<ThemeProvider>(context).init();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context).init();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final pageManager = getIt<PageManager>();
  late List<Surah> surahs;
  late List<Surah> filteredSurahs;
  int pageIndex = 1;
  bool isListView = false;

  @override
  void initState() {
    super.initState();
    surahs = pageManager.surahs;
    filteredSurahs = surahs;
  }

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
                child: child,
                position: animation.drive(
                    Tween(begin: Offset(0, 1), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.ease)))),
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

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            setState(() {
              pageIndex = value;

              if (value == 0) {
                filteredSurahs = pageManager.favoritesNotifier.value;
                filteredSurahs.sort(
                  (a, b) => a.id.compareTo(b.id),
                );
              } else if (value == 1) {
                filteredSurahs = surahs;
              }
            });
          },
          type: BottomNavigationBarType.shifting,
          currentIndex: pageIndex,
          showUnselectedLabels: false,
          selectedItemColor: Theme.of(context).colorScheme.onPrimary,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: "Favorites"),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings")
          ],
        ),
        appBar: pageIndex == 2
            ? AppBar(
                title: const Text("S E T T I N G S"),
              )
            : AppBar(
                title: _isSearching
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                        onChanged: (query) {
                          final favorites = pageManager.favoritesNotifier.value;
                          favorites.sort((a, b) => a.id.compareTo(b.id));

                          // Handle search query here
                          setState(() {
                            // checks if the user is on favorites or home page
                            final listToSearchIn =
                                pageIndex == 0 ? favorites : surahs;
                            if (query != "") {
                              filteredSurahs = listToSearchIn
                                  .where((element) => element.title
                                      .toLowerCase()
                                      .contains(query.toLowerCase()))
                                  .toList();
                            } else {
                              filteredSurahs =
                                  pageIndex == 0 ? favorites : surahs;
                            }
                          });
                        },
                      )
                    : (pageIndex == 0
                        ? const Text("F A V O R I T E S")
                        : const Icon(Icons.home_outlined)),
                actions: [
                  // S E A R C H    I C O N
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) {
                            _searchController.clear();
                            filteredSurahs = pageIndex == 0
                                ? pageManager.favoritesNotifier.value
                                : surahs;
                          }
                        });
                      },
                      icon: Icon(_isSearching ? Icons.close : Icons.search)),

                  // V I E W   S E T T I N G
                  IconButton(
                      onPressed: () => setState(() => isListView = !isListView),
                      icon: Icon(isListView ? Icons.list : Icons.grid_view))
                ],
              ),
        body: pageIndex == 2 ? const SettingsPage() : surahsPage());
  }

  Widget surahsPage() {
    // section for list view of all surahs
    final allSurahsList = ListView.builder(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredSurahs.length + 1,
      itemBuilder: (context, index) {
        if (index == filteredSurahs.length) {
          return const SizedBox(
            height: 100,
          );
        } else {
          // get individual surah
          final Surah surah = filteredSurahs[index];
          // return list tile UI
          return surahTile(context, surah, index);
        }
      },
    );

    // section for grid view of all surahs
    final allSurahsGrid = GridView.count(
        padding: const EdgeInsets.only(bottom: 50),
        childAspectRatio: 0.7,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        crossAxisCount: 3,
        children: List.generate(
          filteredSurahs.length,
          (index) {
            // get individual surah
            final Surah surah = filteredSurahs[index];
            // return list tile UI
            return InkWell(
              child: SurahIcon(surah: surah),
              onTap: () => goToSurah(surah),
            );
          },
        ));

    // Section for recently played list
    final recentlyPlayedBlock = Column(
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
        if (pageIndex == 1)
          ListView(
            children: [
              // Recently Played
              recentlyPlayedBlock,

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
              isListView ? allSurahsList : allSurahsGrid
            ],
          )
        else
          isListView ? allSurahsList : allSurahsGrid,

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

  Widget recentlyPlayedList() {
    return ValueListenableBuilder(
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

  Widget surahTile(BuildContext context, Surah surah, int index) {
    bool isFavorite = pageManager.favoritesNotifier.value.contains(surah);

    return Slidable(
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.green,
            autoClose: true,
            onPressed: (context) => addSurahToPlaylist(context, surah),
            icon: Icons.queue_music,
          )
        ],
      ),
      child: Card(
        elevation: 10,
        child: ListTile(
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset("assets/images/quran.jpg")),
          title: Text(surah.title),
          subtitle: Text("Surah ${surah.id}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(surah.arabicTitle),
              ValueListenableBuilder(
                  valueListenable: pageManager.favoritesNotifier,
                  builder: (_, favorites, __) {
                    return IconButton(
                        onPressed: () {
                          setState(() {
                            if (favorites.contains(surah)) {
                              favorites.remove(surah);
                            } else {
                              favorites.add(surah);
                            }
                            pageManager.changeFavorites(favorites);
                          });
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ));
                  })
            ],
          ),
          onTap: () => goToSurah(surah),
        ),
      ),
    );
  }
}
