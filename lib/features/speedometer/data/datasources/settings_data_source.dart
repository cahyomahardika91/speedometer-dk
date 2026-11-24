import '../../domain/entities/speed_settings.dart';

/// Storage for the user's preferences.
abstract class SettingsDataSource {
  Future<SpeedSettings> read();

  Future<void> write(SpeedSettings settings);
}
