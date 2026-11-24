import 'package:equatable/equatable.dart';

import 'speed_unit.dart';

/// User preferences that survive app restarts.
class SpeedSettings extends Equatable {
  const SpeedSettings({
    this.unit = SpeedUnit.kilometersPerHour,
    this.limitMetersPerSecond = defaultLimitMetersPerSecond,
    this.limitEnabled = true,
    this.soundEnabled = true,
  });

  /// 50 km/h, a common urban limit.
  static const double defaultLimitMetersPerSecond = 50 / 3.6;

  final SpeedUnit unit;
  final double limitMetersPerSecond;
  final bool limitEnabled;
  final bool soundEnabled;

  double get limitInDisplayUnit => unit.toDisplay(limitMetersPerSecond);

  SpeedSettings copyWith({
    SpeedUnit? unit,
    double? limitMetersPerSecond,
    bool? limitEnabled,
    bool? soundEnabled,
  }) {
    return SpeedSettings(
      unit: unit ?? this.unit,
      limitMetersPerSecond: limitMetersPerSecond ?? this.limitMetersPerSecond,
      limitEnabled: limitEnabled ?? this.limitEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    unit,
    limitMetersPerSecond,
    limitEnabled,
    soundEnabled,
  ];
}
