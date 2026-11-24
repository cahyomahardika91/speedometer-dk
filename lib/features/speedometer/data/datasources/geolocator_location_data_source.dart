import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location_readiness.dart';
import '../../domain/entities/speed_sample.dart';
import 'location_data_source.dart';

/// [LocationDataSource] backed by the platform's location services.
class GeolocatorLocationDataSource implements LocationDataSource {
  const GeolocatorLocationDataSource();

  /// Readings above this are treated as GPS noise (~576 km/h).
  static const double _maxPlausibleSpeed = 160;

  @override
  Stream<SpeedSample> watchSpeed() async* {
    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    DateTime? previousTime;
    double? previousLatitude;
    double? previousLongitude;

    await for (final Position position in Geolocator.getPositionStream(
      locationSettings: settings,
    )) {
      final DateTime now = DateTime.now();
      final Duration? elapsed =
          previousTime == null ? null : now.difference(previousTime);

      double speed = position.speed;
      if (!speed.isFinite || speed < 0) {
        speed = _speedFromDistance(
          position: position,
          previousLatitude: previousLatitude,
          previousLongitude: previousLongitude,
          elapsed: elapsed,
        );
      }

      previousTime = now;
      previousLatitude = position.latitude;
      previousLongitude = position.longitude;

      yield SpeedSample(
        metersPerSecond: speed.clamp(0, _maxPlausibleSpeed).toDouble(),
        timestamp: now,
      );
    }
  }

  double _speedFromDistance({
    required Position position,
    required double? previousLatitude,
    required double? previousLongitude,
    required Duration? elapsed,
  }) {
    if (previousLatitude == null ||
        previousLongitude == null ||
        elapsed == null) {
      return 0;
    }

    final double seconds =
        elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    if (seconds <= 0) {
      return 0;
    }

    final double meters = Geolocator.distanceBetween(
      previousLatitude,
      previousLongitude,
      position.latitude,
      position.longitude,
    );
    return meters / seconds;
  }

  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final LocationPermission permission = await Geolocator.requestPermission();
    return _mapPermission(permission);
  }

  @override
  Future<void> openSettings() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.openLocationSettings();
    }
  }

  LocationPermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }
}
