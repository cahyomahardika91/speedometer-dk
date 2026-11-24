import 'package:equatable/equatable.dart';

/// Platform independent view of the location permission state.
enum LocationPermissionStatus { granted, denied, deniedForever, unknown }

/// Whether the app may currently receive GPS updates.
class LocationReadiness extends Equatable {
  const LocationReadiness({
    required this.permission,
    required this.serviceEnabled,
  });

  final LocationPermissionStatus permission;

  /// Whether location services are switched on at the device level.
  final bool serviceEnabled;

  bool get isReady =>
      serviceEnabled && permission == LocationPermissionStatus.granted;

  @override
  List<Object?> get props => <Object?>[permission, serviceEnabled];
}
