import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'speed_sample.dart';

/// Running statistics for the current trip.
///
/// The average is time weighted (integral of speed over time divided by the
/// elapsed time) which is what a real trip computer reports.
class TripStats extends Equatable {
  const TripStats({
    this.durationSeconds = 0,
    this.distanceMeters = 0,
    this.topMetersPerSecond = 0,
    this.speedIntegral = 0,
  });

  /// Total tracked time, in seconds.
  final double durationSeconds;

  /// Distance covered, in metres.
  final double distanceMeters;

  /// Highest speed reached, in metres per second.
  final double topMetersPerSecond;

  /// Internal accumulator: integral of speed over time.
  final double speedIntegral;

  double get averageMetersPerSecond =>
      durationSeconds > 0 ? speedIntegral / durationSeconds : 0;

  bool get isEmpty => durationSeconds <= 0 && topMetersPerSecond <= 0;

  /// Returns new statistics that include [sample], which was [elapsed] after
  /// the previous one.
  TripStats addSample(SpeedSample sample, Duration elapsed) {
    final double seconds =
        elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    if (seconds <= 0) {
      return this;
    }

    final double speed = math.max(0, sample.metersPerSecond);

    return TripStats(
      durationSeconds: durationSeconds + seconds,
      distanceMeters: distanceMeters + speed * seconds,
      topMetersPerSecond: math.max(topMetersPerSecond, speed),
      speedIntegral: speedIntegral + speed * seconds,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    durationSeconds,
    distanceMeters,
    topMetersPerSecond,
    speedIntegral,
  ];
}
