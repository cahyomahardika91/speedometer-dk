import 'package:flutter_test/flutter_test.dart';
import 'package:speedometer/features/speedometer/domain/entities/speed_sample.dart';
import 'package:speedometer/features/speedometer/domain/entities/speed_unit.dart';
import 'package:speedometer/features/speedometer/domain/entities/trip_stats.dart';

void main() {
  group('SpeedUnit', () {
    test('converts metres per second into each unit', () {
      expect(SpeedUnit.kilometersPerHour.toDisplay(10), closeTo(36, 1e-9));
      expect(SpeedUnit.metersPerSecond.toDisplay(10), 10);
      expect(
        SpeedUnit.milesPerHour.toDisplay(10),
        closeTo(22.369362920544, 1e-9),
      );
    });

    test('round trips through every unit', () {
      const double metersPerSecond = 27.5;
      for (final SpeedUnit unit in SpeedUnit.values) {
        expect(
          unit.fromDisplay(unit.toDisplay(metersPerSecond)),
          closeTo(metersPerSecond, 1e-9),
        );
      }
    });

    test('formats with each unit precision', () {
      expect(SpeedUnit.kilometersPerHour.format(10), '36');
      expect(SpeedUnit.metersPerSecond.format(10), '10.0');
      expect(SpeedUnit.milesPerHour.format(10), '22');
    });

    test('falls back to km/h for unknown codes', () {
      expect(SpeedUnit.fromCode('nope'), SpeedUnit.kilometersPerHour);
      expect(SpeedUnit.fromCode(null), SpeedUnit.kilometersPerHour);
    });

    test('presets stay inside the selectable range and on a step', () {
      for (final SpeedUnit unit in SpeedUnit.values) {
        for (final double preset in unit.presets) {
          expect(preset, greaterThanOrEqualTo(unit.minLimit));
          expect(preset, lessThanOrEqualTo(unit.maxLimit));
          expect(preset % unit.limitStep, closeTo(0, 1e-9));
        }
      }
    });
  });

  group('TripStats', () {
    test('starts empty', () {
      const TripStats stats = TripStats();
      expect(stats.isEmpty, isTrue);
      expect(stats.averageMetersPerSecond, 0);
      expect(stats.distanceMeters, 0);
    });

    test('accumulates time weighted average, top speed and distance', () {
      final DateTime start = DateTime(2024);
      TripStats stats = const TripStats();

      stats = stats.addSample(
        SpeedSample(metersPerSecond: 10, timestamp: start),
        const Duration(seconds: 2),
      );
      stats = stats.addSample(
        SpeedSample(
          metersPerSecond: 20,
          timestamp: start.add(const Duration(seconds: 2)),
        ),
        const Duration(seconds: 2),
      );

      expect(stats.durationSeconds, 4);
      expect(stats.averageMetersPerSecond, closeTo(15, 1e-9));
      expect(stats.topMetersPerSecond, 20);
      expect(stats.distanceMeters, closeTo(60, 1e-9));
    });

    test('ignores non positive elapsed time', () {
      final TripStats stats = const TripStats().addSample(
        SpeedSample(metersPerSecond: 10, timestamp: DateTime(2024)),
        Duration.zero,
      );
      expect(stats.isEmpty, isTrue);
    });
  });
}
