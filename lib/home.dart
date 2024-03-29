// Dashboard showcasing all the available Waveform types and their customizations.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

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
  // bool isInitialized = false;

  Future<void> playAudio() async {
    await audioPlayer.play(AssetSource('some.mp3'));
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
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
