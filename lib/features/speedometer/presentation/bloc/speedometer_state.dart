import 'package:equatable/equatable.dart';

import '../../domain/entities/speed_settings.dart';
import '../../domain/entities/speed_unit.dart';
import '../../domain/entities/trip_stats.dart';

enum SpeedometerStatus {
  initial,
  loading,
  ready,
  locationDisabled,
  permissionDenied,
  permissionDeniedForever,
  failure,
}

class SpeedometerState extends Equatable {
  const SpeedometerState({
    this.status = SpeedometerStatus.initial,
    this.unit = SpeedUnit.kilometersPerHour,
    this.speedMetersPerSecond = 0,
    this.limitMetersPerSecond = SpeedSettings.defaultLimitMetersPerSecond,
    this.limitEnabled = true,
    this.soundEnabled = true,
    this.isTracking = true,
    this.stats = const TripStats(),
    this.errorMessage,
  });

  /// GPS jitter margin before the limit counts as exceeded.
  static const double overLimitTolerance = 0.15;

  final SpeedometerStatus status;
  final SpeedUnit unit;
  final double speedMetersPerSecond;
  final double limitMetersPerSecond;
  final bool limitEnabled;
  final bool soundEnabled;
  final bool isTracking;
  final TripStats stats;
  final String? errorMessage;

  double get displaySpeed => unit.toDisplay(speedMetersPerSecond);
  double get displayLimit => unit.toDisplay(limitMetersPerSecond);
  double get displayAverageSpeed =>
      unit.toDisplay(stats.averageMetersPerSecond);
  double get displayTopSpeed => unit.toDisplay(stats.topMetersPerSecond);

  bool get isLive => status == SpeedometerStatus.ready;

  bool get isOverLimit =>
      limitEnabled &&
      speedMetersPerSecond > limitMetersPerSecond + overLimitTolerance;

  /// How close the current speed is to the armed limit (1.0 means at it).
  double get limitRatio {
    if (!limitEnabled || limitMetersPerSecond <= 0) return 0;
    return speedMetersPerSecond / limitMetersPerSecond;
  }

  SpeedometerState copyWith({
    SpeedometerStatus? status,
    SpeedUnit? unit,
    double? speedMetersPerSecond,
    double? limitMetersPerSecond,
    bool? limitEnabled,
    bool? soundEnabled,
    bool? isTracking,
    TripStats? stats,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SpeedometerState(
      status: status ?? this.status,
      unit: unit ?? this.unit,
      speedMetersPerSecond: speedMetersPerSecond ?? this.speedMetersPerSecond,
      limitMetersPerSecond: limitMetersPerSecond ?? this.limitMetersPerSecond,
      limitEnabled: limitEnabled ?? this.limitEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      isTracking: isTracking ?? this.isTracking,
      stats: stats ?? this.stats,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    unit,
    speedMetersPerSecond,
    limitMetersPerSecond,
    limitEnabled,
    soundEnabled,
    isTracking,
    stats,
    errorMessage,
  ];
}
