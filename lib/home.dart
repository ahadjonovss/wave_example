// Dashboard showcasing all the available Waveform types and their customizations.

import 'dart:math';

import 'package:audio_wave/audio_wave.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: WaveformsDashboard(),
    );
  }
}

class WaveformsDashboard extends StatefulWidget {
  const WaveformsDashboard({Key? key}) : super(key: key);

  @override
  State<WaveformsDashboard> createState() => _WaveformsDashboardState();
}

class _WaveformsDashboardState extends State<WaveformsDashboard> {
  ScrollController scrollController = ScrollController();

  AudioPlayer audioPlayer = AudioPlayer();
  List heights = [];
  List waves = [];

  int maxLength = 400;
  int maxWaves = 100;
  Duration currentDuration = const Duration(seconds: 0);

  Duration maxDuration = const Duration(seconds: 1000);

  void _scrollListener() {
    double currentPosition = scrollController.position.pixels -
        MediaQuery.of(context).size.height * 0.5;
    double wavePercent = currentPosition * 100 / maxLength;

    // You can access the scroll position with: scrollController.position
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);

    audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        int second = p.inMicroseconds;
        currentDuration = p;
        // second += 160000;

        double secondP = second * 100 / maxDuration.inMicroseconds;

        double wavePosition = maxLength * secondP / 100;

        scrollController.animateTo(
          wavePosition, // Scroll offset to reach
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );

        waves = List.generate(maxWaves, (index) {
          return AudioWaveBar(
              heightFactor: heights[index],
              color: p.inMilliseconds ~/ 100 - 1 > index
                  ? Color(0xFF007AF5)
                  : Color(0xFF007AF5).withOpacity(0.2));
        });
      });
    });
  }

  Future<void> playAudio() async {
    await audioPlayer.setSource(AssetSource('some.mp3'));
    await audioPlayer.play(AssetSource('some.mp3'));

    maxDuration = (await audioPlayer.getDuration())!;
    maxLength = maxDuration.inMilliseconds ~/ 100 * 8;
    maxWaves = maxDuration.inMilliseconds ~/ 100;
    heights =
        List.generate(maxWaves, (index) => (Random().nextInt(9) + 1) * 0.1);
    waves = List.generate(
        maxWaves,
        (index) => AudioWaveBar(
            heightFactor: (Random().nextInt(9) + 1) * 0.1,
            color: Colors.lightBlueAccent));
    setState(() {});
  }

  void updatePosition(DragUpdateDetails details) {}

  @override
  Widget build(BuildContext context) {
    print(maxLength);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Audio Waveforms'),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: maxLength.toDouble(),
                    height: 150,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5),
                          Column(
                            children: [
                              AudioWave(
                                height: 100,
                                width: maxLength.toDouble(),
                                animation: false,
                                spacing: 2.5,
                                bars: waves.cast(),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: maxLength.toDouble(),
                                height: 30,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: maxDuration.inSeconds,
                                    itemBuilder: (context, index) => SizedBox(
                                        width: 10 * 8,
                                        child: Text(formatSeconds(index)))),
                              )
                            ],
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 200,
                    child: Container(
                      height: 100,
                      width: 4,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
              Text(formatSeconds(currentDuration.inSeconds)),
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
        ));
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
