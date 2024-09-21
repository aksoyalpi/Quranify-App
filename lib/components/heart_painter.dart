import 'dart:ui';

import 'package:flutter/material.dart';

class SurahHeartIcon extends StatelessWidget {
  const SurahHeartIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = Paint();
    paint
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    double width = size.width;
    double height = size.height;

    Path path = Path();
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.25 * width, height * 0.6,
        0.5 * width, height);
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.8 * width, height * 0.1, 1.25 * width, height * 0.6,
        0.5 * width, height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) => true;
}
