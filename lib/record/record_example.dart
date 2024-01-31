import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:wave_example/record/package/flutter_wave_forms.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioRecorder audioRecorder = AudioRecorder();
  // late Duration maxDuration;
  // late int maxLength;
  // late int wavesCount;
  bool isInitialized = false;
  Future<String> getFilePath() async {
    Directory directory;

    if (Platform.isAndroid) {
      directory = (await getExternalStorageDirectory())!; //For Android
    } else {
      directory = await getApplicationDocumentsDirectory(); //For iOS
    }
    return "${directory.path}/${DateTime.now()}rec.mp3";
  }

  Future<void> recordAudio() async {
    if (await audioRecorder.hasPermission()) {
      // Start recording to file
      await audioRecorder.start(const RecordConfig(),
          path: (await getFilePath()));
    }
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
              RecordingWaveDashboard(
                  settings: RecorderSettings(
                      inActiveColor: Colors.green,
                      activeColor: Colors.black,
                      recorder: audioRecorder,
                      height: MediaQuery.of(context).size.height * 0.2,
                      waveHeight: 50,
                      showLabels: true)),
              const SizedBox(height: 100),
              // Text(formatSeconds(currentDuration.inSeconds)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await audioRecorder.pause();
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
                      recordAudio();
                    },
                    child: const Icon(Icons.fiber_manual_record),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() async {
                        final path = await audioRecorder.stop();
                        print("Here is the result $path");
                      });
                    },
                    child: const Icon(Icons.stop),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() async {
                        final path = await audioRecorder.stop();
                        recordAudio();
                      });
                    },
                    child: const Icon(Icons.restart_alt),
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
