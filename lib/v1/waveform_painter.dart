import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final Duration position;
  final Duration audioLength;
  final List<WaveLine> waveLines;
  final bool isPlaying;
  final double spaceBetweenWaves;

  WaveformPainter({
    required this.position,
    required this.audioLength,
    required this.waveLines,
    required this.isPlaying,
    this.spaceBetweenWaves = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = Color(0xFF007AF5)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    final inactivePaint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final centerLineX = size.width / 2;
    final linesPerSecond = 14;
    final pixelsPerSecond = size.width / audioLength.inSeconds;
    final pixelsPerLine = pixelsPerSecond / linesPerSecond;

    // Draw the waveform
    for (int i = 0; i < waveLines.length; i++) {
      final lineX = centerLineX +
          (i - position.inSeconds * linesPerSecond) *
              (pixelsPerLine + spaceBetweenWaves);
      if (lineX < 0 || lineX > size.width) continue;

      final height = waveLines[i].height;
      canvas.drawLine(
        Offset(lineX, centerY - height / 2),
        Offset(lineX, centerY + height / 2),
        lineX < centerLineX ? activePaint : inactivePaint,
      );
    }

    // Draw the center line
    final centerLinePaint = Paint()
      ..color = const Color(0xFF007AF5)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerLineX, 0),
      Offset(centerLineX, size.height),
      centerLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return isPlaying || oldDelegate != this;
  }
}

class WaveLine {
  final double height;

  WaveLine(this.height);
}
