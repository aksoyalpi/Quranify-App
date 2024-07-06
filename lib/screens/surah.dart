import 'package:flutter/material.dart';

class Surah extends StatelessWidget {
  const Surah({super.key, required this.number, required this.surah});

  final int number;
  final String surah;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [Text(number.toString()), Text(surah)],
      ),
    );
  }
}
