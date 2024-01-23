import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'waveform_painter.dart';

class AudioPlayerScreen extends StatefulWidget {
  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration audioLength = Duration.zero;
  late List<WaveLine> waveLines;
  late Duration maxDuration;
  int maxLength = 215;

  @override
  void initState() {
    super.initState();
    setAudio();
    generateWaveLines();
  }

  Future setAudio() async {
    // Replace with your audio file path or URL
    await audioPlayer.setSource(AssetSource('some.mp3'));
    maxDuration = (await audioPlayer.getDuration())!;
    maxLength = 14 * maxDuration.inSeconds * 4;
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      // setState(() {
      // });
    });

    audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        double secondP = p.inSeconds * 100 / maxDuration.inSeconds;
        double s = maxLength * secondP / 100;
        audioLength = p;

        generateWaveLines();

        left = -(s - 215 + 32);

        position = p;
      });
    });
  }

  void generateWaveLines() {
    const linesPerSecond = 7;
    final totalLines = (audioLength.inSeconds * linesPerSecond * 2).toInt();
    const maxBarHeight = 100.0;
    waveLines = List.generate(totalLines, (index) {
      final height = Random().nextDouble() * maxBarHeight;
      return WaveLine(height);
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void togglePlaying() {
    if (isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.resume();
    }
  }

  double left = 215 - 32;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player with Waveform'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: CustomPaint(
              painter: WaveformPainter(
                isPlaying: isPlaying,
                position: position,
                audioLength: audioLength,
                waveLines: waveLines,
              ),
            ),
          ),
          SizedBox(
            height: 20,
            child: Stack(
              children: [
                AnimatedPositioned(
                    duration: const Duration(milliseconds: 1),
                    left: left,
                    bottom: 0,
                    child: SizedBox(
                      height: 20,
                      width: maxLength.toDouble(),
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: maxDuration.inSeconds,
                          clipBehavior: Clip.none,
                          itemBuilder: (context, index) => SizedBox(
                              width: 4 * 14,
                              child: Text(formatSeconds(index)))),
                    ))
              ],
            ),
          ),
          const SizedBox(height: 60),
          Slider(
            value: position.inSeconds
                .toDouble()
                .clamp(0, audioLength.inSeconds.toDouble()),
            min: 0,
            max: audioLength.inSeconds.toDouble(),
            onChanged: (value) {
              final newPosition = Duration(seconds: value.toInt());
              audioPlayer.seek(newPosition);
            },
          ),
          Text(
            formatDuration(position),
            style: const TextStyle(fontSize: 24),
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 64,
            onPressed: togglePlaying,
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String formatSeconds(int seconds) {
    int min = seconds ~/ 60; // Integer division to get minutes
    int sec = seconds % 60; // Modulus to get remaining seconds

    // Pad the minute and second values with zeros if necessary
    String minStr = min.toString().padLeft(2, '0');
    String secStr = sec.toString().padLeft(2, '0');

    return "$minStr:$secStr";
  }
}
