import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/components/modal_sheet_player.dart';
import 'package:quran_fi/components/my_drawer.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/models/surahs_provider.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/pages/surah_page.dart';
import 'package:quran_fi/services/service_locator.dart';
import 'package:quran_fi/themes/theme_provider.dart';

MyAudioHandler _audioHandler = MyAudioHandler();

Future<void> main() async {
  await setupServiceLocator();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => SurahsProvider())
    ],
    child: const MyApp(),
  ));

  // Set preferred orientations for the app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    surahs = pageManager.surahs;
    filteredSurahs = surahs;
  }

  // go to surah with index surahIndex
  void goToSurah(int surahIndex) async {
    // update current surah index
    final pageManager = getIt<PageManager>();
    pageManager.playSurah(surahIndex);

    // navigate to surah page
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurahPage(
            audioHandler: _audioHandler,
          ),
        ));
  }

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  // Handle search query here
                  setState(() {
                    if (query != "") {
                      filteredSurahs = surahs
                          .where((element) => element.title
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                          .toList();
                    } else {
                      filteredSurahs = surahs;
                    }
                  });
                },
              )
            : const Text('S U R A H S'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
              icon: Icon(_isSearching ? Icons.close : Icons.search))
        ],
      ),
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
            itemCount: filteredSurahs.length,
            itemBuilder: (context, index) {
              // get individual surah
              final Surah surah = filteredSurahs[index];

              // return list tile UI
              return ListTile(
                leading: Image.asset("assets/images/quran.jpg"),
                title: Text(surah.title),
                subtitle: Text("Surah ${index + 1}"),
                trailing: Text(surah.arabicTitle),
                onTap: () => goToSurah(index),
              );
            },
          ),

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
                      padding: const EdgeInsets.all(18.0),
                      child: LittleAudioPlayer(),
                    ));
              }
            },
          )
        ],
      ),
    );
  }
}
