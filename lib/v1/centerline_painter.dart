import 'package:flutter/material.dart';

class CenterLinePainter extends CustomPainter {
  final int repaintValue; // Unique value to force repaint

  CenterLinePainter({this.repaintValue = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final centerLinePaint = Paint()
      ..color = const Color(0xFF007AF5)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Draw the center line at a fixed height of 200
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2 - 100), // Starting point
      Offset(size.width / 2, size.height / 2 + 100), // Ending point
      centerLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CenterLinePainter oldDelegate) {
    // Repaint if the repaintValue has changed
    return oldDelegate.repaintValue != repaintValue;
  }
}
