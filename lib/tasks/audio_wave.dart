import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioWavePage extends StatefulWidget {
  @override
  State<AudioWavePage> createState() => _AudioWavePageState();
}

class _AudioWavePageState extends State<AudioWavePage> {
  AudioPlayer audioPlayer = AudioPlayer();
  double left = window.physicalSize.shortestSide / window.devicePixelRatio / 2;
  late double distance;
  double width = window.physicalSize.shortestSide / window.devicePixelRatio;
  Duration maxDuration = Duration.zero;
  int maxWaves = 70;
  bool isPlaying = false;
  List<double> amplitudes = [];

  @override
  void initState() {
    super.initState();
    setAudio();
  }

  Future setAudio() async {
    // Replace with your audio file path or URL
    await audioPlayer.setSource(AssetSource('music.mp3'));
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onPositionChanged.listen((p) {
      int second = p.inSeconds;

      double secondP = second * 100 / maxDuration.inSeconds;
      if (second * 7 < maxWaves * 4) {
        left -= 4 * secondP * 7;
      }
      // print(p);
      setState(() {});
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playMusic() async {
    await audioPlayer.play(AssetSource('music.mp3'));
    maxDuration = (await audioPlayer.getDuration())!;

    maxWaves = maxDuration.inSeconds * 7;
    print(maxDuration.inSeconds * 7);
    amplitudes = List.generate(
        maxDuration.inSeconds * 7, (index) => (Random().nextInt(9) + 1) * 10.0);
    print(amplitudes.length);
    setState(() {});
  }

  void togglePlaying() {
    if (isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Wave Bars'),
      ),
      body: Center(
        child: Column(
          children: [
            Stack(
              children: [
                if (amplitudes.isNotEmpty)
                  AnimatedPositioned(
                    top: 0,
                    bottom: 0,
                    left: left,
                    duration: const Duration(microseconds: 1),
                    child: Container(
                      color: Colors.red,
                      child: CustomPaint(
                        size: Size(maxWaves * 8, 200), // Size of the canvas
                        painter: AudioWaveBarPainter(amplitudes),
                      ),
                    ),
                  ),
                Center(
                  child: SizedBox(
                    child: Container(
                      height: 180,
                      width: 2,
                      color: const Color(0xff007AF5),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    audioPlayer.pause();
                  },
                  child: const Icon(
                    Icons.pause,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    playMusic();
                  },
                  child: const Icon(Icons.play_arrow),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      audioPlayer.seek(const Duration(milliseconds: 0));
                      // right = distance;
                    });
                  },
                  child: const Icon(Icons.replay_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AudioWaveBarPainter extends CustomPainter {
  final List<double> amplitudes;
  AudioWaveBarPainter(this.amplitudes);

  @override
  void paint(Canvas canvas, Size size) {
    double barWidth = 4.0; // Spacing between bars
    Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    // print("MANA LENGTH ${amplitudes.length}");

    for (int i = 0; i < amplitudes.length; i++) {
      print(i);
      double x = i * 2 * barWidth;
      double barHeight = amplitudes[i];
      canvas.drawRect(
        Rect.fromLTWH(x, size.height / 2 - barHeight / 2, barWidth, barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
