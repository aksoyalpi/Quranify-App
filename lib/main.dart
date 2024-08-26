import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/components/my_drawer.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/models/surahs_provider.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/pages/surah_page.dart';
import 'package:quran_fi/services/service_locator.dart';
import 'package:quran_fi/themes/theme_provider.dart';

Future<void> main() async {
  await setupServiceLocator();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => SurahsProvider())
    ],
    child: const MyApp(),
  ));
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
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
  // get surahs provider
  late final dynamic surahsProvider;

  @override
  void initState() {
    super.initState();

    surahsProvider = Provider.of<SurahsProvider>(context, listen: false);
  }

  // go to a surah
  void goToSurah(int surahIndex) async {
    print("Surah Index: $surahIndex");
    // update current surah index
    //surahsProvider.currentSurahIndex = surahIndex;
    final pageManager = getIt<PageManager>();
    pageManager.playSurah(surahIndex);

    // navigate to surah page
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SurahPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("S U R A H S"),
      ),
      drawer: const MyDrawer(),
      body: Consumer<SurahsProvider>(builder: (context, value, child) {
        // get all surahs
        final List<Surah> surahs = value.surahs;

        // return list view UI
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Theme.of(context).colorScheme.secondary,
          ),
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            // get individual surah
            final Surah surah = surahs[index];

            // return list tile UI
            return ListTile(
              leading: Image.asset("assets/images/quran.jpg"),
              title: Text(surah.title),
              subtitle: Text("Surah ${index + 1}"),
              trailing: Text(surah.arabicTitle),
              onTap: () => goToSurah(index),
            );
          },
        );
      }),
    );
  }
}
