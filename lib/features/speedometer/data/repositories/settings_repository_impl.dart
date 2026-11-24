import '../../domain/entities/speed_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dataSource);

  final SettingsDataSource _dataSource;

  @override
  Future<SpeedSettings> load() => _dataSource.read();

  @override
  Future<void> save(SpeedSettings settings) => _dataSource.write(settings);
}
