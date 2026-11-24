import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedometer/core/theme/app_theme.dart';
import 'package:speedometer/features/speedometer/domain/entities/location_readiness.dart';
import 'package:speedometer/features/speedometer/domain/entities/speed_sample.dart';
import 'package:speedometer/features/speedometer/domain/entities/speed_settings.dart';
import 'package:speedometer/features/speedometer/domain/repositories/alert_repository.dart';
import 'package:speedometer/features/speedometer/domain/repositories/location_repository.dart';
import 'package:speedometer/features/speedometer/domain/repositories/settings_repository.dart';
import 'package:speedometer/features/speedometer/domain/usecases/check_location_readiness_use_case.dart';
import 'package:speedometer/features/speedometer/domain/usecases/load_settings_use_case.dart';
import 'package:speedometer/features/speedometer/domain/usecases/open_location_settings_use_case.dart';
import 'package:speedometer/features/speedometer/domain/usecases/play_alert_use_case.dart';
import 'package:speedometer/features/speedometer/domain/usecases/save_settings_use_case.dart';
import 'package:speedometer/features/speedometer/domain/usecases/watch_speed_use_case.dart';
import 'package:speedometer/features/speedometer/presentation/bloc/speedometer_bloc.dart';
import 'package:speedometer/features/speedometer/presentation/bloc/speedometer_event.dart';
import 'package:speedometer/features/speedometer/presentation/pages/speedometer_page.dart';

class _FakeLocationRepository implements LocationRepository {
  final StreamController<SpeedSample> _controller =
      StreamController<SpeedSample>.broadcast();

  void addSample(double metersPerSecond) {
    _controller.add(
      SpeedSample(metersPerSecond: metersPerSecond, timestamp: DateTime.now()),
    );
  }

  Future<void> dispose() => _controller.close();

  @override
  Stream<SpeedSample> watchSpeed() => _controller.stream;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<void> openSettings() async {}
}

class _FakeSettingsRepository implements SettingsRepository {
  SpeedSettings settings = const SpeedSettings();

  @override
  Future<SpeedSettings> load() async => settings;

  @override
  Future<void> save(SpeedSettings settings) async {
    this.settings = settings;
  }
}

class _FakeAlertRepository implements AlertRepository {
  int beeps = 0;

  @override
  Future<void> playBeep() async {
    beeps++;
  }
}

void main() {
  late _FakeLocationRepository location;
  late _FakeAlertRepository alert;
  late SpeedometerBloc bloc;

  // Everything is built inside the test body so the bloc's async handlers run
  // in the test's fake-async zone.
  Future<void> pumpPage(WidgetTester tester) async {
    location = _FakeLocationRepository();
    alert = _FakeAlertRepository();
    bloc = SpeedometerBloc(
      watchSpeed: WatchSpeedUseCase(location),
      loadSettings: LoadSettingsUseCase(_FakeSettingsRepository()),
      saveSettings: SaveSettingsUseCase(_FakeSettingsRepository()),
      checkLocationReadiness: CheckLocationReadinessUseCase(location),
      openLocationSettings: OpenLocationSettingsUseCase(location),
      playAlert: PlayAlertUseCase(alert),
    );
    addTearDown(() async {
      await bloc.close();
      await location.dispose();
    });

    tester.view.physicalSize = const Size(1125, 2001);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    bloc.add(const SpeedometerStarted());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: BlocProvider<SpeedometerBloc>.value(
          value: bloc,
          child: const SpeedometerPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('renders gauge, controls and trip stats on small screens', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    expect(bloc.state.status, SpeedometerStatus.ready);
    expect(find.text('SPEEDOMETER'), findsOneWidget);
    expect(find.text('SPEED LIMIT'), findsOneWidget);
    expect(find.text('AVERAGE'), findsOneWidget);
    expect(find.text('TOP SPEED'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // iPhone SE sized viewport: nothing may overflow.
    tester.view.physicalSize = const Size(960, 1704);
    await tester.pump();
    expect(tester.takeException(), isNull);

    await bloc.close();
  });

  testWidgets('shows live speed and beeps once the limit is exceeded', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    // 30 m/s = 108 km/h, well above the default 50 km/h limit.
    for (int i = 0; i < 8; i++) {
      location.addSample(30);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 700));

    expect(bloc.state.isOverLimit, isTrue);
    expect(bloc.state.displaySpeed, greaterThan(100));
    expect(alert.beeps, greaterThan(0));
    expect(
      tester
          .widgetList<AnimatedOpacity>(
            find.ancestor(
              of: find.text('LIMIT EXCEEDED'),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .any((AnimatedOpacity widget) => widget.opacity == 1),
      isTrue,
    );
    expect(tester.takeException(), isNull);

    // Stops the repeating beep timer before the pending-timer check.
    await bloc.close();
  });

  testWidgets('opens the limit sheet and applies a preset', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text('SPEED LIMIT'));
    await tester.pumpAndSettle();
    expect(find.text('Beep when exceeded'), findsOneWidget);

    await tester.tap(
      find.descendant(of: find.byType(Wrap), matching: find.text('80')),
    );
    await tester.pump();
    expect(bloc.state.displayLimit, closeTo(80, 0.001));

    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();
    expect(find.text('Beep when exceeded'), findsNothing);

    await bloc.close();
  });
}
