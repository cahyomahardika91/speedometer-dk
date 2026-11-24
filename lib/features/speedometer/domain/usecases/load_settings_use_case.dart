import '../entities/speed_settings.dart';
import '../repositories/settings_repository.dart';

class LoadSettingsUseCase {
  const LoadSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<SpeedSettings> call() => _repository.load();
}
