import 'package:flutter/material.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';

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
