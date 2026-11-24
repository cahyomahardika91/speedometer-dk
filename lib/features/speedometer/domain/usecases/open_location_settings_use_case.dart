import '../repositories/location_repository.dart';

/// Sends the user to the system settings that unblock location access.
class OpenLocationSettingsUseCase {
  const OpenLocationSettingsUseCase(this._repository);

  final LocationRepository _repository;

  Future<void> call() => _repository.openSettings();
}
