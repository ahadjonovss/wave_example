import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:wave_example/wave/package/wave_bar.dart';

class RecorderSettings {
  AudioRecorder? recorder;
  Color? activeColor;
  Color? inActiveColor;
  Color? backgroundColor;
  Color? centerLineColor;
  double height;
  double? centerLineWidth;
  double waveHeight;
  TextStyle? labelStyle;
  bool showLabels;

  RecorderSettings(
      {this.recorder,
      required this.height,
      this.showLabels = false,
      this.centerLineWidth,
      this.backgroundColor,
      this.activeColor,
      this.centerLineColor,
      this.inActiveColor,
      this.labelStyle,
      required this.waveHeight});
}

class RecordingWaveDashboard extends StatefulWidget {
  RecorderSettings settings;
  RecordingWaveDashboard({required this.settings, Key? key}) : super(key: key);

  @override
  State<RecordingWaveDashboard> createState() => _RecordingWaveDashboardState();
}

class _RecordingWaveDashboardState extends State<RecordingWaveDashboard> {
  final record = AudioRecorder();

  double left = window.physicalSize.width / window.devicePixelRatio;
  late RecorderSettings settings;
  Duration maxDuration = const Duration(minutes: 5);
  int maxLength = window.physicalSize.width / window.devicePixelRatio ~/ 2;
  int wavesCount = 70;
  Duration cD = const Duration(seconds: 0);
  bool isRecording = false;

  Future<void> setUpSettings() async {
    settings = widget.settings;
    audioRecorder = settings.recorder ?? AudioRecorder();
    maxLength = maxDuration.inMilliseconds ~/ 100 * 8;
    wavesCount = maxDuration.inMilliseconds ~/ 100;

    settings.centerLineWidth = widget.settings.centerLineWidth ?? 4;
    settings.height = widget.settings.showLabels
        ? widget.settings.height
        : widget.settings.height;
    settings.activeColor =
        widget.settings.activeColor ?? const Color(0xFF007AF5);
    settings.centerLineColor =
        widget.settings.centerLineColor ?? const Color(0xFF007AF5);
    settings.inActiveColor = widget.settings.inActiveColor ??
        const Color(0xFF007AF5).withOpacity(0.2);

    settings.backgroundColor = widget.settings.backgroundColor ??
        const Color(0xFF007AF5).withOpacity(0.04);
    heights = List.generate(wavesCount, (index) => 0.05);
    setState(() {
      regenerateWaves(const Duration(seconds: 1));
    });
  }

  void regenerateWaves(Duration currentDuration) {
    waves = List.generate(wavesCount, (index) {
      if (heights[index] == 0.05 &&
          currentDuration.inMilliseconds ~/ 100 - 1 > index) {
        heights[index] = (Random().nextInt(9) + 1) * 0.1;
      }
      return AudioWaveBar(
          heightFactor: heights[index],
          color: currentDuration.inMilliseconds ~/ 100 - 1 > index
              ? settings.activeColor!
              : settings.inActiveColor!);
    });

    setState(() {});
  }

  late AudioRecorder audioRecorder;
  List heights = [];
  List waves = [];

  @override
  void initState() {
    setUpSettings();
    super.initState();
    audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((state) {
      cD = Duration(milliseconds: cD.inMilliseconds + 100);
      double secondP = cD.inMicroseconds * 100 / maxDuration.inMicroseconds;
      double wavePosition = maxLength * secondP / 100;
      left = -wavePosition;
      regenerateWaves(cD);
    });

    audioRecorder.onStateChanged().listen((event) {
      isRecording = event == RecordState.record;
      if (event == RecordState.stop) {
        cD = const Duration(seconds: 0);
        heights = List.generate(wavesCount, (index) {
          return 0.05;
        });
        regenerateWaves(cD);
        print("Done");
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: settings.showLabels ? settings.height + 50 : settings.height,
      child: Stack(
        children: [
          AnimatedPositioned(
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            left: left,
            child: SizedBox(
              height:
                  settings.showLabels ? settings.height + 50 : settings.height,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.5),
                    SizedBox(
                      height: settings.showLabels
                          ? settings.height + 50
                          : settings.height,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              height: settings.height,
                              color: settings.backgroundColor,
                              child: AudioWave(
                                height: settings.waveHeight,
                                width: maxLength.toDouble(),
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
                            if (settings.showLabels) const SizedBox(height: 20),
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
                                          child: Text(formatSeconds(index)));
                                    }),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.5),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            right: isRecording
                ? MediaQuery.of(context).size.width * 0.47
                : MediaQuery.of(context).size.width * 0.526,
            child: Container(
              height: settings.height,
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
