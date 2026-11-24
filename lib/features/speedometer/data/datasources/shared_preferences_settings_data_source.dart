import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/speed_settings.dart';
import '../../domain/entities/speed_unit.dart';
import 'settings_data_source.dart';

/// [SettingsDataSource] backed by [SharedPreferences].
class SharedPreferencesSettingsDataSource implements SettingsDataSource {
  const SharedPreferencesSettingsDataSource();

  static const String _unitKey = 'speedometer.unit';
  static const String _limitKey = 'speedometer.limit_meters_per_second';
  static const String _limitEnabledKey = 'speedometer.limit_enabled';
  static const String _soundEnabledKey = 'speedometer.sound_enabled';

  @override
  Future<SpeedSettings> read() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return SpeedSettings(
      unit: SpeedUnit.fromCode(prefs.getString(_unitKey)),
      limitMetersPerSecond:
          prefs.getDouble(_limitKey) ??
          SpeedSettings.defaultLimitMetersPerSecond,
      limitEnabled: prefs.getBool(_limitEnabledKey) ?? true,
      soundEnabled: prefs.getBool(_soundEnabledKey) ?? true,
    );
  }

  @override
  Future<void> write(SpeedSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_unitKey, settings.unit.code);
    await prefs.setDouble(_limitKey, settings.limitMetersPerSecond);
    await prefs.setBool(_limitEnabledKey, settings.limitEnabled);
    await prefs.setBool(_soundEnabledKey, settings.soundEnabled);
  }
}
