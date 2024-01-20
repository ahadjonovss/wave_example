// Dashboard showcasing all the available Waveform types and their customizations.

import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:wave_example/tasks/my_notes.dart';

import 'load_audio_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyNotesPage(),
    );
  }
}

class WaveformsDashboard extends StatefulWidget {
  double scope;

  WaveformsDashboard({required this.scope, Key? key}) : super(key: key);

  @override
  State<WaveformsDashboard> createState() => _WaveformsDashboardState();
}

class _WaveformsDashboardState extends State<WaveformsDashboard> {
  double right = -(window.physicalSize.shortestSide / window.devicePixelRatio);
  late double distance;
  double width = window.physicalSize.shortestSide / window.devicePixelRatio;

  late Duration elapsedDuration;
  late AudioPlayer audioPlayer;
  late List<double> samples;
  double sliderValue = 0;
  int totalSamples = 256;
  WaveformType waveformType = WaveformType.polygon;
  late WaveformCustomizations waveformCustomizations;

  late List<String> audioData;

  List<List<String>> audioDataList = [
    [
      'assets/soy.json',
      'some.mp3',
    ],
    [
      'assets/soy.json',
      'some.mp3',
    ],
    [
      'assets/soy.json',
      'some.mp3',
    ],
  ];

  Future<void> parseData() async {
    final json = await rootBundle.loadString(audioData[0]);
    Map<String, dynamic> audioDataMap = {
      "json": json,
      "totalSamples": maxDuration.inSeconds,
    };
    final samplesData = await compute(loadparseJson, audioDataMap);

    setState(() {
      samples = samplesData["samples"];
    });
  }

  Duration maxDuration = const Duration(seconds: 1000);
  late ValueListenable<Duration> progress;

  Future<void> playAudio() async {
    await audioPlayer.play(AssetSource('some.mp3'));

    maxDuration = (await audioPlayer.getDuration())!;
  }

  @override
  void initState() {
    super.initState();
    right *= widget.scope;
    width *= widget.scope;
    distance = right;
    audioPlayer = AudioPlayer();
    audioData = audioDataList[0];

    parseData();

    samples = [];
    elapsedDuration = const Duration();

    audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        elapsedDuration = maxDuration;
        sliderValue = 1;
      });
    });
    audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        int second = p.inMicroseconds;

        double secondP = second * 100 / maxDuration.inMicroseconds;
        print("-------");
        print(
            "Current SECOND ${p.inSeconds} of ${maxDuration.inSeconds} : $secondP %");

        double distanceC = distance * secondP / 100;
        print(
            "Distance: ${distance - distanceC} of $distance :${distanceC * 100 / distance} %");

        right = distance - distanceC;
        elapsedDuration = p;
      });
    });
    totalSamples = maxDuration.inSeconds;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    waveformCustomizations = WaveformCustomizations(
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.width,
    );
  }

  void updatePosition(DragUpdateDetails details) {
    if (right - details.delta.dx > (-width) &&
        right - details.delta.dx < width) {
      // double width = MediaQuery.of(context).size.width * 0.5;
      right -= details.delta.dx;
      double number = right + width;

      double percentage = (number / width) * 100;
      int second = calculatePercentage(maxDuration.inSeconds, percentage);
      audioPlayer.seek(Duration(seconds: second));

      audioPlayer.seek(Duration(seconds: second));
    }
    setState(() {
      // Update position on drag
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Audio Waveforms'),
        ),
        body: Column(
          //    mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(microseconds: 1),
                  right: right,
                  child: GestureDetector(
                    onHorizontalDragUpdate: updatePosition,
                    onTap: () {},
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          SquigglyWaveformExample(
                            maxDuration: maxDuration,
                            elapsedDuration: elapsedDuration,
                            samples: samples,
                            waveformCustomizations: waveformCustomizations,
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
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
                      sliderValue = 0;
                      audioPlayer.seek(const Duration(milliseconds: 0));
                      right = distance;
                    });
                  },
                  child: const Icon(Icons.replay_outlined),
                ),
              ],
            ),
          ],
        ));
  }

  int calculatePercentage(int number, double percent) {
    return number * percent ~/ 100;
  }
}

class SquigglyWaveformExample extends StatelessWidget {
  const SquigglyWaveformExample({
    Key? key,
    required this.maxDuration,
    required this.elapsedDuration,
    required this.samples,
    required this.waveformCustomizations,
  }) : super(key: key);

  final Duration maxDuration;
  final Duration elapsedDuration;
  final List<double> samples;
  final WaveformCustomizations waveformCustomizations;

  @override
  Widget build(BuildContext context) {
    return SquigglyWaveform(
      maxDuration: maxDuration,
      elapsedDuration: elapsedDuration,
      samples: samples,
      height: waveformCustomizations.height,
      width: waveformCustomizations.width,
      inactiveColor: waveformCustomizations.inactiveColor,
      invert: waveformCustomizations.invert,
      absolute: waveformCustomizations.absolute,
      activeColor: waveformCustomizations.activeColor,
      showActiveWaveform: waveformCustomizations.showActiveWaveform,
      strokeWidth: waveformCustomizations.borderWidth,
    );
  }
}

enum WaveformType {
  polygon,
  rectangle,
  squiggly,
  curvedPolygon,
}

class WaveformCustomizations {
  WaveformCustomizations({
    required this.height,
    required this.width,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.blue,
    this.activeGradient,
    this.inactiveGradient,
    this.style = PaintingStyle.stroke,
    this.showActiveWaveform = true,
    this.absolute = false,
    this.invert = false,
    this.borderWidth = 1.0,
    this.activeBorderColor = Colors.white,
    this.inactiveBorderColor = Colors.white,
    this.isRoundedRectangle = false,
    this.isCentered = false,
  });

  double height;
  double width;
  Color inactiveColor;
  Gradient? inactiveGradient;
  bool invert;
  bool absolute;
  Color activeColor;
  Gradient? activeGradient;
  bool showActiveWaveform;
  PaintingStyle style;
  double borderWidth;
  Color activeBorderColor;
  Color inactiveBorderColor;
  bool isRoundedRectangle;
  bool isCentered;
}
