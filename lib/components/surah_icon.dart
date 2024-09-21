import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/surah.dart';

class SurahIcon extends StatelessWidget {
  const SurahIcon({super.key, required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
            child: Container(
          height: 75,
          width: 75,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.primary)),
          child: Center(
              child: Text(
            surah.id.toString(),
            style: GoogleFonts.bodoniModa(fontSize: 20),
          )),
        )),
        Text(surah.arabicTitle),
        Text(surah.title)
      ],
    );
  }
}
