import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wave_example/record/recorder_cubit.dart';
import 'package:wave_example/wave/example.dart';

void main() {
  runApp(BlocProvider(
    create: (context) => AudioRecorderCubit(),
    child: MyApp(),
  ));
}
