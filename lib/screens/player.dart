import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_fi/screens/commons/player_buttons.dart';
import "package:quran/quran.dart" as quran;

class Player extends StatefulWidget {
  const Player({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    _audioPlayer = AudioPlayer();

    _audioPlayer
        .setAudioSource(AudioSource.uri(
            Uri.parse(quran.getAudioURLBySurah(widget.surahNumber))))
        .catchError((error) => print(error));

    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text(quran.getSurahName(widget.surahNumber)),
            PlayerButtons(_audioPlayer),
          ],
        ),
      ),
    );
  }
}
