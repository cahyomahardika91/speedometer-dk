import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/speed_unit.dart';
import '../bloc/speedometer_bloc.dart';
import '../bloc/speedometer_event.dart';
import '../bloc/speedometer_state.dart';

/// Opens the speed limit editor. The bloc is passed explicitly because the
/// sheet lives in the navigator's overlay, above the provider in `home`.
Future<void> showSpeedLimitSheet(BuildContext context) {
  final SpeedometerBloc bloc = context.read<SpeedometerBloc>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder:
        (BuildContext _) => BlocProvider<SpeedometerBloc>.value(
          value: bloc,
          child: const SpeedLimitSheet(),
        ),
  );
}

class SpeedLimitSheet extends StatelessWidget {
  const SpeedLimitSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final SpeedometerBloc bloc = context.read<SpeedometerBloc>();

    return BlocBuilder<SpeedometerBloc, SpeedometerState>(
      builder: (BuildContext context, SpeedometerState state) {
        final SpeedUnit unit = state.unit;
        final double limit = unit
            .toDisplay(state.limitMetersPerSecond)
            .clamp(unit.minLimit, unit.maxLimit);

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    const Text(
                      'SPEED LIMIT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    _ArmedChip(enabled: state.limitEnabled),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      limit.round().toString(),
                      style: const TextStyle(
                        fontSize: 44,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      unit.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: limit,
                  min: unit.minLimit,
                  max: unit.maxLimit,
                  divisions: unit.limitDivisions,
                  label: '${limit.round()} ${unit.label}',
                  onChanged:
                      (double value) => bloc.add(
                        SpeedometerLimitChanged(
                          limitMetersPerSecond: unit.fromDisplay(value),
                        ),
                      ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${unit.minLimit.round()}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${unit.maxLimit.round()} ${unit.label}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      unit.presets
                          .map(
                            (double preset) => _PresetChip(
                              label: '${preset.round()}',
                              selected: (limit - preset).abs() < 0.51,
                              onTap:
                                  () => bloc.add(
                                    SpeedometerLimitChanged(
                                      limitMetersPerSecond: unit.fromDisplay(
                                        preset,
                                      ),
                                    ),
                                  ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        state.limitEnabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        size: 18,
                        color:
                            state.limitEnabled
                                ? AppColors.warning
                                : AppColors.textMuted,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Beep when exceeded',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Repeats while you are over the limit',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: state.limitEnabled,
                        activeTrackColor: AppColors.warning.withValues(
                          alpha: 0.35,
                        ),
                        activeColor: AppColors.warning,
                        onChanged:
                            (bool value) => bloc.add(
                              SpeedometerLimitToggled(enabled: value),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArmedChip extends StatelessWidget {
  const _ArmedChip({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color color = enabled ? AppColors.success : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        enabled ? 'ARMED' : 'OFF',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: color,
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.primary.withValues(alpha: 0.16)
                  : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
