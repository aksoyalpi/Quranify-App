import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/themes/theme_provider.dart';

class NeuBox extends StatelessWidget {
  const NeuBox(
      {super.key, required this.child, this.sigmaX, this.sigmaY, this.border});

  final Widget? child;
  final double? sigmaX, sigmaY;
  final bool? border;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX ?? 30, sigmaY: sigmaY ?? 30),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
            border: (border ?? true)
                ? Border.all(color: Colors.white.withOpacity(0.2), width: 2)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}
