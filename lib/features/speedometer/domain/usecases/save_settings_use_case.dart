import '../entities/speed_settings.dart';
import '../repositories/settings_repository.dart';

class SaveSettingsUseCase {
  const SaveSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(SpeedSettings settings) => _repository.save(settings);
}
