import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_fi/models/surah.dart';

class RecentlyPlayedCard extends StatelessWidget {
  const RecentlyPlayedCard({super.key, required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.secondary)),
      color: Theme.of(context).colorScheme.surface,
      shadowColor: Theme.of(context).colorScheme.primary,
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Surah
            Text(
              surah.title,
              style: GoogleFonts.bodoniModa(fontSize: 18),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              surah.arabicTitle,
              style: GoogleFonts.bodoniModa(fontSize: 15),
            )
          ],
        ),
      ),
    );
  }
}
