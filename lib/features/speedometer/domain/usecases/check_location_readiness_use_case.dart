import '../entities/location_readiness.dart';
import '../repositories/location_repository.dart';

/// Checks — and optionally asks for — the permission needed to read GPS speed.
class CheckLocationReadinessUseCase {
  const CheckLocationReadinessUseCase(this._repository);

  final LocationRepository _repository;

  Future<LocationReadiness> call({bool requestPermission = false}) async {
    final bool serviceEnabled = await _repository.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationReadiness(
        permission: LocationPermissionStatus.unknown,
        serviceEnabled: false,
      );
    }

    final LocationPermissionStatus permission =
        requestPermission
            ? await _repository.requestPermission()
            : await _repository.checkPermission();

    return LocationReadiness(permission: permission, serviceEnabled: true);
  }
}
