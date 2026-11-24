import 'package:equatable/equatable.dart';

import '../../domain/entities/speed_sample.dart';
import '../../domain/entities/speed_unit.dart';

sealed class SpeedometerEvent extends Equatable {
  const SpeedometerEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Boots the feature: restores settings and starts the GPS stream.
class SpeedometerStarted extends SpeedometerEvent {
  const SpeedometerStarted();
}

/// A new speed reading arrived from the location stream.
class SpeedometerStreamUpdated extends SpeedometerEvent {
  const SpeedometerStreamUpdated({required this.sample});

  final SpeedSample sample;

  @override
  List<Object?> get props => <Object?>[sample];
}

/// The location stream failed.
class SpeedometerStreamFailed extends SpeedometerEvent {
  const SpeedometerStreamFailed({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

class SpeedometerUnitChanged extends SpeedometerEvent {
  const SpeedometerUnitChanged({required this.unit});

  final SpeedUnit unit;

  @override
  List<Object?> get props => <Object?>[unit];
}

class SpeedometerLimitChanged extends SpeedometerEvent {
  const SpeedometerLimitChanged({required this.limitMetersPerSecond});

  final double limitMetersPerSecond;

  @override
  List<Object?> get props => <Object?>[limitMetersPerSecond];
}

class SpeedometerLimitToggled extends SpeedometerEvent {
  const SpeedometerLimitToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

class SpeedometerSoundToggled extends SpeedometerEvent {
  const SpeedometerSoundToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

/// Clears the average/top/distance counters.
class SpeedometerTripReset extends SpeedometerEvent {
  const SpeedometerTripReset();
}

/// Pauses or resumes trip tracking (the live speed keeps updating).
class SpeedometerTrackingToggled extends SpeedometerEvent {
  const SpeedometerTrackingToggled();
}

/// Re-checks location readiness, asking for the permission again.
class SpeedometerPermissionRequested extends SpeedometerEvent {
  const SpeedometerPermissionRequested();
}

/// Sends the user to the relevant system settings page.
class SpeedometerSettingsOpened extends SpeedometerEvent {
  const SpeedometerSettingsOpened();
}
