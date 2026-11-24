import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/location_readiness.dart';
import '../../domain/entities/speed_sample.dart';
import '../../domain/entities/speed_settings.dart';
import '../../domain/entities/trip_stats.dart';
import '../../domain/usecases/check_location_readiness_use_case.dart';
import '../../domain/usecases/load_settings_use_case.dart';
import '../../domain/usecases/open_location_settings_use_case.dart';
import '../../domain/usecases/play_alert_use_case.dart';
import '../../domain/usecases/save_settings_use_case.dart';
import '../../domain/usecases/watch_speed_use_case.dart';
import 'speedometer_event.dart';
import 'speedometer_state.dart';

class SpeedometerBloc extends Bloc<SpeedometerEvent, SpeedometerState> {
  SpeedometerBloc({
    required WatchSpeedUseCase watchSpeed,
    required LoadSettingsUseCase loadSettings,
    required SaveSettingsUseCase saveSettings,
    required CheckLocationReadinessUseCase checkLocationReadiness,
    required OpenLocationSettingsUseCase openLocationSettings,
    required PlayAlertUseCase playAlert,
  }) : _watchSpeed = watchSpeed,
       _loadSettings = loadSettings,
       _saveSettings = saveSettings,
       _checkLocationReadiness = checkLocationReadiness,
       _openLocationSettings = openLocationSettings,
       _playAlert = playAlert,
       super(const SpeedometerState()) {
    on<SpeedometerStarted>(_onStarted);
    on<SpeedometerStreamUpdated>(_onStreamUpdated);
    on<SpeedometerStreamFailed>(_onStreamFailed);
    on<SpeedometerUnitChanged>(_onUnitChanged);
    on<SpeedometerLimitChanged>(_onLimitChanged);
    on<SpeedometerLimitToggled>(_onLimitToggled);
    on<SpeedometerSoundToggled>(_onSoundToggled);
    on<SpeedometerTripReset>(_onTripReset);
    on<SpeedometerTrackingToggled>(_onTrackingToggled);
    on<SpeedometerPermissionRequested>(_onPermissionRequested);
    on<SpeedometerSettingsOpened>(_onSettingsOpened);
  }

  static const Duration _alarmInterval = Duration(milliseconds: 1600);
  static const Duration _persistDebounce = Duration(milliseconds: 250);
  static const Duration _maxSampleGap = Duration(seconds: 5);

  final WatchSpeedUseCase _watchSpeed;
  final LoadSettingsUseCase _loadSettings;
  final SaveSettingsUseCase _saveSettings;
  final CheckLocationReadinessUseCase _checkLocationReadiness;
  final OpenLocationSettingsUseCase _openLocationSettings;
  final PlayAlertUseCase _playAlert;

  StreamSubscription<SpeedSample>? _subscription;
  Timer? _alarmTimer;
  Timer? _persistTimer;
  DateTime? _lastSampleTime;

  Future<void> _onStarted(
    SpeedometerStarted event,
    Emitter<SpeedometerState> emit,
  ) async {
    emit(state.copyWith(status: SpeedometerStatus.loading));

    try {
      final SpeedSettings settings = await _loadSettings();
      if (isClosed) return;
      emit(
        state.copyWith(
          unit: settings.unit,
          limitMetersPerSecond: settings.limitMetersPerSecond,
          limitEnabled: settings.limitEnabled,
          soundEnabled: settings.soundEnabled,
        ),
      );
    } catch (_) {
      // Defaults are perfectly usable, so a failed read is not fatal.
    }

    await _startListening(emit, requestPermission: true);
  }

  Future<void> _onPermissionRequested(
    SpeedometerPermissionRequested event,
    Emitter<SpeedometerState> emit,
  ) async {
    emit(state.copyWith(status: SpeedometerStatus.loading));
    await _startListening(emit, requestPermission: true);
  }

  Future<void> _onSettingsOpened(
    SpeedometerSettingsOpened event,
    Emitter<SpeedometerState> emit,
  ) async {
    await _openLocationSettings();
    if (isClosed) return;
    await _startListening(emit, requestPermission: false);
  }

  Future<void> _startListening(
    Emitter<SpeedometerState> emit, {
    required bool requestPermission,
  }) async {
    await _subscription?.cancel();
    _subscription = null;

    try {
      final LocationReadiness readiness = await _checkLocationReadiness(
        requestPermission: requestPermission,
      );
      if (isClosed) return;

      if (!readiness.serviceEnabled) {
        emit(state.copyWith(status: SpeedometerStatus.locationDisabled));
        return;
      }

      switch (readiness.permission) {
        case LocationPermissionStatus.deniedForever:
          emit(
            state.copyWith(status: SpeedometerStatus.permissionDeniedForever),
          );
          return;
        case LocationPermissionStatus.denied:
        case LocationPermissionStatus.unknown:
          emit(state.copyWith(status: SpeedometerStatus.permissionDenied));
          return;
        case LocationPermissionStatus.granted:
          break;
      }

      emit(state.copyWith(status: SpeedometerStatus.ready, clearError: true));
      _lastSampleTime = null;

      _subscription = _watchSpeed().listen(
        (SpeedSample sample) {
          if (!isClosed) {
            add(SpeedometerStreamUpdated(sample: sample));
          }
        },
        onError: (Object error) {
          if (!isClosed) {
            add(SpeedometerStreamFailed(message: '$error'));
          }
        },
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: SpeedometerStatus.failure,
          errorMessage: 'Could not start GPS: $error',
        ),
      );
    }
  }

  void _onStreamUpdated(
    SpeedometerStreamUpdated event,
    Emitter<SpeedometerState> emit,
  ) {
    final SpeedSample sample = event.sample;

    // Light exponential smoothing so the needle glides instead of jumping.
    final double target = sample.metersPerSecond.clamp(0.0, 120.0).toDouble();
    double smoothed = state.speedMetersPerSecond * 0.4 + target * 0.6;
    if ((smoothed - target).abs() < 0.12) {
      smoothed = target;
    }
    if (smoothed < 0.1) {
      smoothed = 0;
    }

    TripStats stats = state.stats;
    final DateTime? previous = _lastSampleTime;
    _lastSampleTime = sample.timestamp;

    if (state.isTracking && previous != null) {
      Duration elapsed = sample.timestamp.difference(previous);
      if (elapsed.isNegative) {
        elapsed = Duration.zero;
      } else if (elapsed > _maxSampleGap) {
        elapsed = _maxSampleGap;
      }
      if (elapsed > Duration.zero) {
        stats = stats.addSample(
          SpeedSample(metersPerSecond: smoothed, timestamp: sample.timestamp),
          elapsed,
        );
      }
    }

    emit(
      state.copyWith(
        status: SpeedometerStatus.ready,
        speedMetersPerSecond: smoothed,
        stats: stats,
        clearError: true,
      ),
    );
    _syncAlarm();
  }

  void _onStreamFailed(
    SpeedometerStreamFailed event,
    Emitter<SpeedometerState> emit,
  ) {
    _cancelAlarm();
    emit(
      state.copyWith(
        status: SpeedometerStatus.failure,
        speedMetersPerSecond: 0,
        errorMessage: 'GPS error: ${event.message}',
      ),
    );
  }

  void _onUnitChanged(
    SpeedometerUnitChanged event,
    Emitter<SpeedometerState> emit,
  ) {
    if (event.unit == state.unit) return;

    // Keep the physical limit, snapped into the new unit's range.
    final double inNewUnit = event.unit.toDisplay(state.limitMetersPerSecond);
    final double clamped = inNewUnit.clamp(
      event.unit.minLimit,
      event.unit.maxLimit,
    );
    final double snapped = event.unit.roundToStep(clamped);

    emit(
      state.copyWith(
        unit: event.unit,
        limitMetersPerSecond: event.unit.fromDisplay(snapped),
      ),
    );
    _syncAlarm();
    _schedulePersist();
  }

  void _onLimitChanged(
    SpeedometerLimitChanged event,
    Emitter<SpeedometerState> emit,
  ) {
    final double inDisplay = state.unit
        .toDisplay(event.limitMetersPerSecond)
        .clamp(state.unit.minLimit, state.unit.maxLimit);

    emit(
      state.copyWith(limitMetersPerSecond: state.unit.fromDisplay(inDisplay)),
    );
    _syncAlarm();
    _schedulePersist();
  }

  void _onLimitToggled(
    SpeedometerLimitToggled event,
    Emitter<SpeedometerState> emit,
  ) {
    emit(state.copyWith(limitEnabled: event.enabled));
    _syncAlarm();
    _schedulePersist();
  }

  void _onSoundToggled(
    SpeedometerSoundToggled event,
    Emitter<SpeedometerState> emit,
  ) {
    emit(state.copyWith(soundEnabled: event.enabled));
    _syncAlarm();
    _schedulePersist();
  }

  void _onTripReset(
    SpeedometerTripReset event,
    Emitter<SpeedometerState> emit,
  ) {
    _lastSampleTime = null;
    emit(state.copyWith(stats: const TripStats()));
  }

  void _onTrackingToggled(
    SpeedometerTrackingToggled event,
    Emitter<SpeedometerState> emit,
  ) {
    final bool tracking = !state.isTracking;
    if (tracking) {
      _lastSampleTime = null;
    }
    emit(state.copyWith(isTracking: tracking));
  }

  /// Starts, keeps alive or stops the repeating beep depending on the state.
  void _syncAlarm() {
    final bool shouldBeep = state.isOverLimit && state.soundEnabled;

    if (!shouldBeep) {
      _cancelAlarm();
      return;
    }

    if (_alarmTimer != null) return;

    unawaited(_playAlert());
    _alarmTimer = Timer.periodic(_alarmInterval, (Timer timer) {
      if (isClosed || !state.isOverLimit || !state.soundEnabled) {
        timer.cancel();
        if (identical(_alarmTimer, timer)) {
          _alarmTimer = null;
        }
        return;
      }
      unawaited(_playAlert());
    });
  }

  void _cancelAlarm() {
    _alarmTimer?.cancel();
    _alarmTimer = null;
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    final SpeedSettings settings = SpeedSettings(
      unit: state.unit,
      limitMetersPerSecond: state.limitMetersPerSecond,
      limitEnabled: state.limitEnabled,
      soundEnabled: state.soundEnabled,
    );
    _persistTimer = Timer(_persistDebounce, () {
      unawaited(_saveSettings(settings).catchError((Object _) {}));
    });
  }

  @override
  Future<void> close() async {
    _cancelAlarm();
    _persistTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
