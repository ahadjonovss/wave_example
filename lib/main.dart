import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wave_example/record/record_example.dart';
import 'package:wave_example/record/recorder_cubit.dart';

void main() {
  runApp(BlocProvider(
    create: (context) => AudioRecorderCubit(),
    child: MyApp(),
  ));
}
