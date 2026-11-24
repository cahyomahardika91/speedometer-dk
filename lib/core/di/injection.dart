import '../../features/speedometer/data/datasources/geolocator_location_data_source.dart';
import '../../features/speedometer/data/datasources/shared_preferences_settings_data_source.dart';
import '../../features/speedometer/data/repositories/alert_repository_impl.dart';
import '../../features/speedometer/data/repositories/location_repository_impl.dart';
import '../../features/speedometer/data/repositories/settings_repository_impl.dart';
import '../../features/speedometer/domain/repositories/alert_repository.dart';
import '../../features/speedometer/domain/repositories/location_repository.dart';
import '../../features/speedometer/domain/repositories/settings_repository.dart';
import '../../features/speedometer/domain/usecases/check_location_readiness_use_case.dart';
import '../../features/speedometer/domain/usecases/load_settings_use_case.dart';
import '../../features/speedometer/domain/usecases/open_location_settings_use_case.dart';
import '../../features/speedometer/domain/usecases/play_alert_use_case.dart';
import '../../features/speedometer/domain/usecases/save_settings_use_case.dart';
import '../../features/speedometer/domain/usecases/watch_speed_use_case.dart';
import '../services/beep_player.dart';

/// Hand-rolled composition root: builds every data source, repository and use
/// case once, so the presentation layer only depends on the domain.
class AppDependencies {
  const AppDependencies._({
    required this.watchSpeed,
    required this.loadSettings,
    required this.saveSettings,
    required this.checkLocationReadiness,
    required this.openLocationSettings,
    required this.playAlert,
  });

  factory AppDependencies.create() {
    final LocationRepository locationRepository = LocationRepositoryImpl(
      const GeolocatorLocationDataSource(),
    );
    final SettingsRepository settingsRepository = SettingsRepositoryImpl(
      const SharedPreferencesSettingsDataSource(),
    );
    final AlertRepository alertRepository = AlertRepositoryImpl(BeepPlayer());

    return AppDependencies._(
      watchSpeed: WatchSpeedUseCase(locationRepository),
      loadSettings: LoadSettingsUseCase(settingsRepository),
      saveSettings: SaveSettingsUseCase(settingsRepository),
      checkLocationReadiness: CheckLocationReadinessUseCase(locationRepository),
      openLocationSettings: OpenLocationSettingsUseCase(locationRepository),
      playAlert: PlayAlertUseCase(alertRepository),
    );
  }

  final WatchSpeedUseCase watchSpeed;
  final LoadSettingsUseCase loadSettings;
  final SaveSettingsUseCase saveSettings;
  final CheckLocationReadinessUseCase checkLocationReadiness;
  final OpenLocationSettingsUseCase openLocationSettings;
  final PlayAlertUseCase playAlert;
}
