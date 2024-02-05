import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

enum AudioRecorderState { idle, loading, recording, paused, stopped }

class AudioRecorderCubit extends Cubit<AudioRecorderState> {
  String? _path;

  AudioRecorderCubit() : super(AudioRecorderState.idle);

  Future initRecorder() async {
    var status = await Permission.microphone.request();
    if (status == PermissionStatus.permanentlyDenied) {
      debugPrint("Microphone permission permanently denied");
      // await AppSettings.openAppSettings(type: AppSettingsType.sound);
    } else if (status != PermissionStatus.granted) {
      // await AppSettings.openAppSettings(type: AppSettingsType.sound);
      throw Exception('Microphone permission not granted');
    } else {
      debugPrint("Microphone permission status $status");
    }
  }

  startOrResumeRecording(AudioRecorder recorder) async {
    emit(AudioRecorderState.loading);
    bool isPaused = await recorder.isPaused();
    if (isPaused) {
      resumeRecording(recorder);
    } else {
      if (await recorder.hasPermission()) {
        Directory dir = await path_provider.getApplicationDocumentsDirectory();
        String filename =
            "recording_${DateTime.now().millisecondsSinceEpoch}.m4a";
        _path = '${dir.path}/$filename';
        await recorder.start(const RecordConfig(), path: _path!);
        debugPrint("Recording paused ${recorder.isPaused}");
        emit(AudioRecorderState.recording);
      } else {
        await initRecorder();
      }
    }
  }

  void pauseRecording(AudioRecorder recorder) async {
    await recorder.pause();
    emit(AudioRecorderState.paused);
  }

  void resumeRecording(AudioRecorder recorder) async {
    await recorder.resume();
    emit(AudioRecorderState.recording);
  }

  void stopRecording(AudioRecorder recorder) async {
    await recorder.stop();
    emit(AudioRecorderState.stopped);
  }

  String? get path => _path;

  void reset(AudioRecorder recorder) {
    emit(AudioRecorderState.idle);
    _path = null;
    recorder.stop();
  }
}
