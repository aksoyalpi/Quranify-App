import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/components/my_drawer.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/models/surahs_provider.dart';
import 'package:quran_fi/pages/surah_page.dart';
import 'package:quran_fi/services/audio_handler.dart';
import 'package:quran_fi/themes/theme_provider.dart';

MyAudioHandler _audioHandler = MyAudioHandler();

Future<void> main() async {
  // Ensure that the Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
      androidNotificationChannelName: 'Quran playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    ),
  );
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  //late final dynamic surahsProvider;

  @override
  void initState() {
    super.initState();

    //surahsProvider = Provider.of<SurahsProvider>(context, listen: false);
  }

  // go to a surah
  void goToSurah(int surahIndex) async {
    // update current surah index
    //surahsProvider.currentSurahIndex = surahIndex;

    _audioHandler.skipToQueueItem(surahIndex);

    // navigate to surah page
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurahPage(
            audioHandler: _audioHandler,
          ),
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
