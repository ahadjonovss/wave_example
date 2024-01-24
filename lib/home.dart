// Dashboard showcasing all the available Waveform types and their customizations.

import 'dart:math';
import 'dart:ui';

import 'package:audio_wave/audio_wave.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioPlayer audioPlayer = AudioPlayer();
  late Duration maxDuration;
  late int maxLength;
  late int wavesCount;
  bool isInitialized = false;

  Future<void> playAudio() async {
    await audioPlayer.play(AssetSource('some.mp3'));
  }

  void setUpAudio() async {
    await audioPlayer.setSource(AssetSource('some.mp3'));
    maxDuration = (await audioPlayer.getDuration())!;
    maxLength = maxDuration.inMilliseconds ~/ 100 * 8;
    wavesCount = maxDuration.inMilliseconds ~/ 100;
    isInitialized = true;
    setState(() {});
  }

  @override
  void initState() {
    setUpAudio();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Visibility(
                visible: isInitialized,
                child: WaveformsDashboard(
                  settings: WaveSettings(
                      maxDuration: maxDuration,
                      maxLength: maxLength,
                      wavesCount: wavesCount,
                      audioPlayer: audioPlayer,
                      height: 300,
                      waveHeight: 130,
                      showLabels: true),
                ),
              ),
              const SizedBox(height: 100),
              // Text(formatSeconds(currentDuration.inSeconds)),
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
                      if (audioPlayer.state == PlayerState.paused) {
                        audioPlayer.resume();
                      } else {
                        await playAudio();
                      }
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
                      });
                    },
                    child: const Icon(Icons.replay_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveSettings {
  AudioPlayer? audioPlayer;
  Color? activeColor;
  Color? inActiveColor;
  Color? backgroundColor;
  Color? centerLineColor;
  double height;
  double? centerLineWidth;
  double waveHeight;
  TextStyle? labelStyle;
  bool showLabels;
  num maxLength;
  int wavesCount;
  Duration maxDuration;

  WaveSettings(
      {this.audioPlayer,
      required this.maxLength,
      required this.wavesCount,
      required this.height,
      this.showLabels = false,
      required this.maxDuration,
      this.centerLineWidth,
      this.backgroundColor,
      this.activeColor,
      this.centerLineColor,
      this.inActiveColor,
      this.labelStyle,
      required this.waveHeight});
}

class WaveformsDashboard extends StatefulWidget {
  WaveSettings settings;
  WaveformsDashboard({required this.settings, Key? key}) : super(key: key);

  @override
  State<WaveformsDashboard> createState() => _WaveformsDashboardState();
}

class _WaveformsDashboardState extends State<WaveformsDashboard> {
  double left = window.physicalSize.width / window.devicePixelRatio / 2;
  late WaveSettings settings;

  void setUpSettings() {
    settings = widget.settings;
    audioPlayer = settings.audioPlayer ?? AudioPlayer();

    settings.centerLineWidth = settings.centerLineWidth ?? 4;
    settings.height =
        settings.showLabels ? settings.height + 50 : settings.height;
    settings.activeColor = settings.activeColor ?? const Color(0xFF007AF5);
    settings.centerLineColor =
        settings.centerLineColor ?? const Color(0xFF007AF5);
    settings.activeColor =
        settings.inActiveColor ?? const Color(0xFF007AF5).withOpacity(0.2);
    settings.backgroundColor =
        settings.backgroundColor ?? const Color(0xFF007AF5).withOpacity(0.04);
    heights = List.generate(
        settings.wavesCount, (index) => (Random().nextInt(9) + 1) * 0.1);
  }

  void regenerateWaves(Duration currentDuration) {
    print(settings.wavesCount);
    print("Salom wave ${settings.wavesCount} va height ${heights.length}");
    waves = List.generate(settings.wavesCount, (index) {
      return AudioWaveBar(
          heightFactor: heights[index],
          color: currentDuration.inMilliseconds ~/ 100 - 1 > index
              ? const Color(0xFF007AF5)
              : const Color(0xFF007AF5).withOpacity(0.2));
    });
  }

  late AudioPlayer audioPlayer;
  List heights = [];
  List waves = [];
  Duration currentDuration = const Duration(seconds: 0);

  @override
  void initState() {
    setUpSettings();
    super.initState();

    audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        int second = p.inMicroseconds;
        currentDuration = p;
        double secondP = second * 100 / settings.maxDuration.inMicroseconds;
        double wavePosition = settings.maxLength * secondP / 100;
        left = -wavePosition;
        regenerateWaves(p);
      });
    });
  }

  Future<void> playAudio() async {
    print(settings.wavesCount);

    regenerateWaves(const Duration(seconds: 0));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: settings.height,
      child: Stack(
        children: [
          AnimatedPositioned(
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            left: left,
            child: SizedBox(
              width: settings.maxLength.toDouble(),
              height: settings.height,
              child: GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  setState(() {
                    left += details.delta.dx;
                  });
                },
                onHorizontalDragStart: (details) {
                  audioPlayer.pause();
                },
                onHorizontalDragEnd: (DragEndDetails details) {
                  double percent = left.abs() * 100 / settings.maxLength;
                  int second = settings.maxDuration.inSeconds * percent ~/ 100;
                  audioPlayer.seek(Duration(seconds: second + 1));
                  audioPlayer.resume();
                },
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    height: settings.height,
                    child: Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5),
                        SizedBox(
                          height: settings.height,
                          child: Column(
                            children: [
                              Container(
                                height: settings.waveHeight,
                                color: settings.backgroundColor,
                                child: AudioWave(
                                  height: settings.waveHeight,
                                  width: settings.maxLength.toDouble(),
                                  animation: false,
                                  spacing: 2.5,
                                  bars: waves.cast(),
                                ),
                              ),
                              // SizedBox(
                              //   width: maxLength.toDouble(),
                              //   height: 4,
                              //   child: ListView.builder(
                              //       scrollDirection: Axis.horizontal,
                              //       shrinkWrap: true,
                              //       itemCount: maxDuration.inSeconds * 4,
                              //       itemBuilder: (context, index) {
                              //         print(index % 4 == 0);
                              //         return Container(
                              //             margin: const EdgeInsets.only(
                              //                 right: 20),
                              //             color: Colors.black
                              //                 .withOpacity(0.3),
                              //             height: index % 4 == 0 ? 2 : 3,
                              //             width: 1);
                              //       }),
                              // ),
                              if (settings.showLabels)
                                const SizedBox(height: 20),
                              if (settings.showLabels)
                                SizedBox(
                                  width: settings.maxLength.toDouble(),
                                  height: 30,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: settings.maxDuration.inSeconds,
                                      itemBuilder: (context, index) => SizedBox(
                                          width: 10 * 8,
                                          child: Text(formatSeconds(index)))),
                                )
                            ],
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            right: audioPlayer.state == PlayerState.paused
                ? MediaQuery.of(context).size.width * 0.525
                : MediaQuery.of(context).size.width * 0.48,
            child: Container(
              height: settings.waveHeight,
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
