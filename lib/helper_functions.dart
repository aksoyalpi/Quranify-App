import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
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

  if (context.mounted) showSnackBar(context, text);
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

void submitFeedback(UserFeedback feedback) async {
  String path = "";
  String timestamp = DateTime.timestamp().toIso8601String();
  try {
    Directory root = await getTemporaryDirectory();
    String directoryPath = "${root.path}/quran_fi";
    // Create the directory if it doesn't exist
    await Directory(directoryPath).create(recursive: true);
    String filePath = "$directoryPath/$timestamp.jpg";
    final file = await File(filePath).writeAsBytes(feedback.screenshot);
    path = file.path;
  } catch (e) {
    debugPrint(e.toString());
  }

  final Email email = Email(
      body: feedback.text,
      subject: "Quranify Feedback",
      recipients: ["alaksoftware@gmail.com"],
      attachmentPaths: [path]);

  await FlutterEmailSender.send(email);
}
