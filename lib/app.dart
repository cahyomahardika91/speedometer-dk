import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/speedometer/presentation/bloc/speedometer_bloc.dart';
import 'features/speedometer/presentation/bloc/speedometer_event.dart';
import 'features/speedometer/presentation/pages/speedometer_page.dart';

class SpeedometerApp extends StatelessWidget {
  const SpeedometerApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speedometer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: BlocProvider<SpeedometerBloc>(
        create:
            (BuildContext context) => SpeedometerBloc(
              watchSpeed: dependencies.watchSpeed,
              loadSettings: dependencies.loadSettings,
              saveSettings: dependencies.saveSettings,
              checkLocationReadiness: dependencies.checkLocationReadiness,
              openLocationSettings: dependencies.openLocationSettings,
              playAlert: dependencies.playAlert,
            )..add(const SpeedometerStarted()),
        child: const SpeedometerPage(),
      ),
    );
  }
}
