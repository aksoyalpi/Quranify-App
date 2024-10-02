import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/pages/settings_page.dart';
import 'package:quran_fi/pages/surahs_page.dart';
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
        body: pageIndex == 2
            ? const SettingsPage()
            : SurahsPage(
                surahs: filteredSurahs,
                isFavoritesPage: (pageIndex == 0),
              ));
  }
}
