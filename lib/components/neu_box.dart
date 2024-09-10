import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/themes/theme_provider.dart';

class NeuBox extends StatelessWidget {
  const NeuBox({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // is dark mode
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 2.5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                // darker shadow on bottom right
                /*BoxShadow(
                    color: isDarkMode ? Colors.black : Colors.grey.shade500,
                    blurRadius: 14,
                    offset: const Offset(4, 4)),

                // lighter shadow on top left
                BoxShadow(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                    blurRadius: 15,
                    offset: const Offset(-4, -4)),*/
              ]),
          child: child,
        ),
      ),
    );
  }
}
