// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'wave_bar.dart';

class WaveSettings {
  AudioPlayer? audioPlayer;
  Color? activeColor;
  Color? inActiveColor;
  Color? backgroundColor;
  Color? centerLineColor;
  double height;
  double? centerLineWidth;
  double waveHeight;
  double waveBGHeight;
  TextStyle? labelStyle;
  bool showLabels;
  bool isAsset;

  String path;

  WaveSettings(
      {this.audioPlayer,
      required this.path,
      this.isAsset = false,
      required this.height,
      this.showLabels = false,
      this.centerLineWidth,
      this.backgroundColor,
      this.activeColor,
      this.centerLineColor,
      this.inActiveColor,
      this.labelStyle,
      required this.waveHeight,
      required this.waveBGHeight});
}

class WaveformsDashboard extends StatefulWidget {
  WaveSettings settings;
  WaveformsDashboard({required this.settings, Key? key}) : super(key: key);

  @override
  State<WaveformsDashboard> createState() => _WaveformsDashboardState();
}

class _WaveformsDashboardState extends State<WaveformsDashboard> {
  double left = 0;

  late WaveSettings settings;
  Duration maxDuration = const Duration(seconds: 100);
  int maxLength = 215;
  int wavesCount = 70;

  Future<void> setUpSettings() async {
    settings = widget.settings;
    audioPlayer = settings.audioPlayer ?? AudioPlayer();
    if (settings.isAsset) {
      await audioPlayer.setSourceAsset(settings.path);
    } else {
      await audioPlayer.setSourceUrl(settings.path);
    }
    maxDuration =
        (await audioPlayer.getDuration()) ?? const Duration(seconds: 100);
    maxLength = (maxDuration.inMilliseconds ~/ 100 * 8);
    wavesCount = maxDuration.inMilliseconds ~/ 100;

    settings.centerLineWidth = widget.settings.centerLineWidth ?? 4;
    settings.height = widget.settings.showLabels
        ? widget.settings.height + 50
        : widget.settings.height;
    settings.activeColor =
        widget.settings.activeColor ?? const Color(0xFF007AF5);
    settings.centerLineColor =
        widget.settings.centerLineColor ?? const Color(0xFF007AF5);
    settings.inActiveColor = widget.settings.inActiveColor ??
        const Color(0xFF007AF5).withOpacity(0.2);

    settings.backgroundColor = widget.settings.backgroundColor ??
        const Color(0xFF007AF5).withOpacity(0.04);
    heights =
        List.generate(wavesCount, (index) => (Random().nextInt(9) + 1) * 0.1);

    setState(() {
      regenerateWaves(const Duration(seconds: 0));
    });
  }

  void regenerateWaves(Duration currentDuration) {
    waves = List.generate(wavesCount, (currentIndex) {
      bool ableToChange =
          currentDuration.inMilliseconds ~/ 100 > currentIndex &&
              currentDuration.inMicroseconds != 0;
      return AudioWaveBar(
        heightFactor: heights[currentIndex].toDouble(),
        color: ableToChange ? settings.activeColor! : settings.inActiveColor!,
      );
    });
  }

  late AudioPlayer audioPlayer;
  List heights = [];
  List waves = [];

  @override
  void initState() {
    setUpSettings();
    super.initState();

    audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        int second = p.inMicroseconds;

        double secondP = second * 100 / maxDuration.inMicroseconds;
        double wavePosition = maxLength * secondP / 100;
        left = -wavePosition;
        Duration s = Duration(milliseconds: p.inMilliseconds);
        regenerateWaves(s);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: settings.height,
      child: Stack(
        children: [
          AnimatedPositioned(
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 200),
            left: left,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: settings.waveBGHeight,
                    color: settings.backgroundColor,
                    width: MediaQuery.of(context).size.width * 0.5),
                SizedBox(
                  width: maxLength.toDouble(),
                  height: settings.height,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      setState(() {
                        left += details.delta.dx;
                      });
                    },
                    onHorizontalDragStart: (details) async {
                      await audioPlayer.pause();
                    },
                    onHorizontalDragEnd: (DragEndDetails details) async {
                      double percent = left.abs() * 100 / maxLength;
                      int second =
                          ((maxDuration.inSeconds.ceil()) * percent ~/ 100)
                              .ceil();
                      audioPlayer.seek(Duration(seconds: second));
                      await audioPlayer.resume();
                    },
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        height: settings.waveHeight,
                        child: SizedBox(
                          height: settings.height,
                          child: Column(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: settings.waveBGHeight,
                                  minWidth: MediaQuery.of(context).size.width,
                                ),
                                height: settings.waveBGHeight,
                                color: settings.backgroundColor,
                                child: AudioWave(
                                  height: settings.waveHeight,
                                  width: maxLength.toDouble(),
                                  animation: false,
                                  spacing: 2.5,
                                  bars: waves.cast(),
                                ),
                              ),
                              if (settings.showLabels)
                                const SizedBox(height: 20),
                              if (settings.showLabels)
                                SizedBox(
                                  width: maxLength.toDouble(),
                                  height: 30,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: maxDuration.inSeconds,
                                      itemBuilder: (context, index) {
                                        return SizedBox(
                                          width: 10 * 8,
                                          child: Text(formatSeconds(index)),
                                        );
                                      }),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                    height: settings.waveBGHeight,
                    color: settings.backgroundColor,
                    width: MediaQuery.of(context).size.width * 0.5),
              ],
            ),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width * 0.5,
            child: Container(
              height: settings.waveBGHeight,
              width: 4,
              color: settings.centerLineColor,
            ),
          ),
        ],
      ),
    );
  }

  String formatSeconds(int seconds) {
    int min = seconds ~/ 60; // Integer division to get minutes
    int sec = seconds % 60; // Modulus to get remaining seconds

    String minStr = min.toString().padLeft(2, '0');
    String secStr = sec.toString().padLeft(2, '0');

    return "$minStr:$secStr";
  }
}
