import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:provider/provider.dart';
import 'package:quran_fi/helper_functions.dart';

import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/pages/settings_page.dart';
import 'package:quran_fi/pages/surahs_page.dart';
import 'package:quran_fi/services/in_app_tour_target.dart';
import 'package:quran_fi/services/service_locator.dart';
import 'package:quran_fi/services/shared_prefs.dart';
import 'package:quran_fi/themes/theme_provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
  bool isChooseMode = false;
  final List<Surah> choosedSurahs = [];

  final surahPageKey = GlobalKey();
  final searchIconKey = GlobalKey();
  final changeViewKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;
  void _initAddSiteInAppTour() {
    tutorialCoachMark = TutorialCoachMark(
      targets: surahsTargetsPage(
          surahIconKey: surahPageKey,
          changeViewKey: changeViewKey,
          searchIconKey: searchIconKey),
      colorShadow: Colors.purple.shade900,
      paddingFocus: 10,
      hideSkip: true,
      opacityShadow: 0.8,
      onFinish: () => SharedPrefs.setIsFirstTime(false),
    );
  }

  void _showInAppTour() {
    Future.delayed(const Duration(seconds: 1), () {
      tutorialCoachMark.show(context: context);
    });
  }

  @override
  void initState() {
    super.initState();
    surahs = pageManager.surahs;
    filteredSurahs = surahs;
    SharedPrefs.getIsFirstTime().then(
      (isFirstTime) {
        if (isFirstTime) {
          _initAddSiteInAppTour();
          _showInAppTour();
        }
      },
    );
  }

  bool handlePop(bool isChooseMode) {
    if (isChooseMode) {
      pageManager.switchChooseMode();
    }
    return false;
  }

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: pageManager.isChooseMode,
        builder: (_, isChooseMode, __) => PopScope(
              canPop: false,
              onPopInvoked: (didPop) => handlePop(isChooseMode),
              child: Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
                    child: GNav(
                        selectedIndex: pageIndex,
                        padding: const EdgeInsets.all(16),
                        tabBackgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        onTabChange: (value) {
                          setState(() {
                            pageIndex = value;

                            if (value == 0) {
                              filteredSurahs =
                                  pageManager.favoritesNotifier.value;
                              filteredSurahs.sort(
                                (a, b) => a.id.compareTo(b.id),
                              );
                            } else if (value == 1) {
                              filteredSurahs = surahs;
                            }
                          });
                        },
                        gap: 8,
                        tabs: const [
                          GButton(
                              icon: Icons.favorite_border, text: "Favorites"),
                          GButton(icon: Icons.home, text: "Home"),
                          GButton(icon: Icons.settings, text: "Settings"),
                        ]),
                  ),
                  appBar: pageIndex == 2
                      ? AppBar(
                          title: const Text("S E T T I N G S"),
                        )
                      : isChooseMode
                          ? chooseModeAppBar()
                          : defaultAppBar(),
                  body: pageIndex == 2
                      ? const SettingsPage()
                      : SurahsPage(
                          surahIconKey: surahPageKey,
                          surahs: filteredSurahs,
                          isFavoritesPage: (pageIndex == 0),
                          isListView: isListView,
                        )),
            ));
  }

  PreferredSizeWidget? chooseModeAppBar() => AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: pageManager.switchChooseMode,
        ),
        actions: [
          IconButton(
              onPressed: () {
                final chosenSurahsCount =
                    pageManager.choosedSurahs.value.length;
                pageManager.addChosenSurahs();
                pageManager.switchChooseMode();
                showSnackBar(
                    context, "Added $chosenSurahsCount Surahs to Playlist");
              },
              icon: const Icon(Icons.playlist_add)),
          IconButton(
              onPressed: () {
                pageManager.addChosenSurahsToFavorites();
                pageManager.switchChooseMode();
              },
              icon: const Icon(Icons.favorite_border)),
        ],
      );

  AppBar defaultAppBar() => AppBar(
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
                    final listToSearchIn = pageIndex == 0 ? favorites : surahs;
                    if (query != "") {
                      filteredSurahs = listToSearchIn
                          .where((element) => element.title
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                          .toList();
                    } else {
                      filteredSurahs = pageIndex == 0 ? favorites : surahs;
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
              key: searchIconKey,
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

          // L A Y O U T  S E T T I N G
          IconButton(
              key: changeViewKey,
              onPressed: () => setState(() => isListView = !isListView),
              icon: Icon(isListView ? Icons.list : Icons.grid_view)),
        ],
      );
}
