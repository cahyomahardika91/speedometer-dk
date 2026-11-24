import '../../domain/entities/location_readiness.dart';
import '../../domain/entities/speed_sample.dart';

/// Raw source of GPS readings and permission state.
abstract class LocationDataSource {
  Stream<SpeedSample> watchSpeed();

  Future<bool> isLocationServiceEnabled();

  Future<LocationPermissionStatus> checkPermission();

  Future<LocationPermissionStatus> requestPermission();

  Future<void> openSettings();
}
