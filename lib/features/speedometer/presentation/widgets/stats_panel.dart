import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/speed_formatter.dart';
import '../../domain/entities/speed_unit.dart';
import '../bloc/speedometer_state.dart';

/// Average, top speed and distance for the current trip.
class StatsPanel extends StatelessWidget {
  const StatsPanel({super.key, required this.state});

  final SpeedometerState state;

  @override
  Widget build(BuildContext context) {
    final SpeedUnit unit = state.unit;
    final double distance = state.stats.distanceMeters;

    return Row(
      children: <Widget>[
        Expanded(
          child: _StatTile(
            label: 'AVERAGE',
            value: SpeedFormatter.speedValue(
              state.stats.averageMetersPerSecond,
              unit,
            ),
            unitLabel: unit.label,
            icon: Icons.timeline_rounded,
            accent: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: 'TOP SPEED',
            value: SpeedFormatter.speedValue(
              state.stats.topMetersPerSecond,
              unit,
            ),
            unitLabel: unit.label,
            icon: Icons.bolt_rounded,
            accent: AppColors.warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: 'DISTANCE',
            value: SpeedFormatter.distanceValue(distance, unit),
            unitLabel: SpeedFormatter.distanceUnitLabel(distance, unit),
            icon: Icons.route_rounded,
            accent: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.unitLabel,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String unitLabel;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.surface,
            AppColors.backgroundAlt.withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 13, color: accent),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  unitLabel,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
