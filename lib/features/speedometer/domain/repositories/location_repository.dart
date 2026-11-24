import '../entities/location_readiness.dart';
import '../entities/speed_sample.dart';

/// Access to the device's position and speed.
abstract class LocationRepository {
  /// Continuous stream of speed readings.
  Stream<SpeedSample> watchSpeed();

  Future<bool> isLocationServiceEnabled();

  Future<LocationPermissionStatus> checkPermission();

  Future<LocationPermissionStatus> requestPermission();

  /// Opens the most relevant system settings page (app or location).
  Future<void> openSettings();
}
