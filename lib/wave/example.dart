import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package/flutter_wave_forms.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioPlayer audioPlayer = AudioPlayer();
  // late Duration maxDuration;
  // late int maxLength;
  // late int wavesCount;
  bool isInitialized = false;

  Future<void> playAudio() async {
    await audioPlayer.play(UrlSource(url));
  }

  // void setUpAudio() async {
  //   await audioPlayer.setSource(AssetSource('some.mp3'));
  //   maxDuration = (await audioPlayer.getDuration())!;
  //   maxLength = maxDuration.inMilliseconds ~/ 100 * 8;
  //   wavesCount = maxDuration.inMilliseconds ~/ 100;
  //   isInitialized = true;
  //   setState(() {});
  // }

  @override
  void initState() {
    // setUpAudio();
    super.initState();
  }

  String url =
      "https://firebasestorage.googleapis.com/v0/b/fir-example-e58e4.appspot.com/o/some.mp3?alt=media&token=3f94d450-2164-4dad-8741-43e37f71f15d";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              WaveformsDashboard(
                settings: WaveSettings(
                  inActiveColor: Colors.green,
                  activeColor: Colors.black,
                  audioPlayer: audioPlayer,
                  height: 300,
                  waveBGHeight: 200,
                  waveHeight: 100,
                  showLabels: true,
                  isAsset: false,
                  path: url,
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
                        await audioPlayer.resume();
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
