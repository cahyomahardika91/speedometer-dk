import '../../features/speedometer/domain/entities/speed_unit.dart';

/// Presentation helpers shared by the widgets.
abstract final class SpeedFormatter {
  static const double _metersPerMile = 1609.344;
  static const double _feetPerMeter = 3.280839895;

  /// Speed value (without its unit label) for the given [unit].
  static String speedValue(double metersPerSecond, SpeedUnit unit) {
    return unit.toDisplay(metersPerSecond).toStringAsFixed(unit.decimals);
  }

  /// Distance value (without its unit label) for the given [unit].
  static String distanceValue(double meters, SpeedUnit unit) {
    if (unit == SpeedUnit.milesPerHour) {
      final double miles = meters / _metersPerMile;
      return miles < 0.1
          ? (meters * _feetPerMeter).round().toString()
          : miles.toStringAsFixed(2);
    }
    return meters < 1000
        ? meters.round().toString()
        : (meters / 1000).toStringAsFixed(2);
  }

  /// Distance unit label matching [distanceValue].
  static String distanceUnitLabel(double meters, SpeedUnit unit) {
    if (unit == SpeedUnit.milesPerHour) {
      return meters / _metersPerMile < 0.1 ? 'ft' : 'mi';
    }
    return meters < 1000 ? 'm' : 'km';
  }

  /// `m:ss` or `h:mm:ss` representation of a trip duration.
  static String duration(Duration value) {
    final int hours = value.inHours;
    final int minutes = value.inMinutes.remainder(60);
    final int seconds = value.inSeconds.remainder(60);
    final String twoDigits = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$twoDigits';
    }
    return '$minutes:$twoDigits';
  }
}
