import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:wave_example/record/package/flutter_wave_forms.dart';
import 'package:wave_example/record/recorder_cubit.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioRecorder audioRecorder = AudioRecorder();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<AudioRecorderCubit, AudioRecorderState>(
                builder: (context, state) {
                  return RecordingWaveDashboard(
                      settings: RecorderSettings(
                          isRefresh: state == AudioRecorderState.idle,
                          inActiveColor: Colors.green,
                          activeColor: Colors.black,
                          recorder: audioRecorder,
                          height: MediaQuery.of(context).size.height * 0.2,
                          waveHeight: 50,
                          showLabels: true));
                },
              ),
              const SizedBox(height: 100),
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
                      context
                          .read<AudioRecorderCubit>()
                          .startOrResumeRecording(audioRecorder);
                    },
                    child: const Icon(Icons.fiber_manual_record),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      context
                          .read<AudioRecorderCubit>()
                          .stopRecording(audioRecorder);
                    },
                    child: const Icon(Icons.stop),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      context.read<AudioRecorderCubit>().reset(audioRecorder);
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
