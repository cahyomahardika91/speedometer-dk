import '../entities/speed_settings.dart';

/// Persistence for the user's speedometer preferences.
abstract class SettingsRepository {
  Future<SpeedSettings> load();

  Future<void> save(SpeedSettings settings);
}
