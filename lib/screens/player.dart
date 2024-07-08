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
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    _audioPlayer = AudioPlayer();

    _audioPlayer
        .setAudioSource(AudioSource.uri(
            Uri.parse(quran.getAudioURLBySurah(widget.surahNumber))))
        .catchError((error) => print(error));

    /// Listen to audio duration
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(quran.getSurahName(widget.surahNumber)),
            Column(
              children: [
                PlayerButtons(_audioPlayer),
                Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {},
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(position)),
                      Text(formatTime(duration)),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes);
  final seconds = twoDigits(duration.inSeconds);

  return [
    if (duration.inHours > 0) hours,
    minutes,
    seconds,
  ].join(":");
}
