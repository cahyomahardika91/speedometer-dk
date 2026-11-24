import '../../domain/entities/location_readiness.dart';
import '../../domain/entities/speed_sample.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final LocationDataSource _dataSource;

  @override
  Stream<SpeedSample> watchSpeed() => _dataSource.watchSpeed();

  @override
  Future<bool> isLocationServiceEnabled() =>
      _dataSource.isLocationServiceEnabled();

  @override
  Future<LocationPermissionStatus> checkPermission() =>
      _dataSource.checkPermission();

  @override
  Future<LocationPermissionStatus> requestPermission() =>
      _dataSource.requestPermission();

  @override
  Future<void> openSettings() => _dataSource.openSettings();
}
