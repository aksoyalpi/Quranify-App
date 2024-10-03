import 'package:flutter/material.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';

void addSurahToPlaylist(BuildContext context, Surah surah) async {
  final pageManager = getIt<PageManager>();
  String text = "Added";

  bool alreadyInPlaylist = await pageManager.add(surah);

  if (alreadyInPlaylist) {
    text = "Surah already in playlist";
  }

  showSnackBar(context, text);
}

void showSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
    elevation: 10,
    margin: const EdgeInsets.all(5),
    behavior: SnackBarBehavior.floating,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
