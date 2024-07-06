import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_fi/screens/player.dart';

class AllSurahs extends StatefulWidget {
  const AllSurahs({super.key});

  @override
  State<AllSurahs> createState() => _AllSurahsState();
}

class _AllSurahsState extends State<AllSurahs> {
  final surahs = List.generate(
      quran.totalSurahCount, (index) => quran.getSurahName(index + 1));

  final surahAudios = List.generate(
      quran.totalSurahCount, (index) => quran.getAudioURLBySurah(index + 1));

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: surahs.length,
      itemBuilder: (context, index) => ListTile(
        leading: Text((index + 1).toString()),
        title: Text(surahs[index]),
        trailing: Text(quran.getSurahNameArabic(index + 1)),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Player(surahNumber: index + 1),
              ));
        },
      ),
    );
  }
}
