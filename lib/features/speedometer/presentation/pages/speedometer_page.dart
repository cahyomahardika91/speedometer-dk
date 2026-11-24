import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/speedometer_bloc.dart';
import '../bloc/speedometer_event.dart';
import '../bloc/speedometer_state.dart';
import '../widgets/speed_gauge.dart';
import '../widgets/speed_limit_sheet.dart';
import '../widgets/stats_panel.dart';
import '../widgets/unit_selector.dart';

class SpeedometerPage extends StatelessWidget {
  const SpeedometerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: SafeArea(
          child: BlocConsumer<SpeedometerBloc, SpeedometerState>(
            listenWhen:
                (SpeedometerState previous, SpeedometerState current) =>
                    previous.status != current.status &&
                    current.status == SpeedometerStatus.failure,
            listener: (BuildContext context, SpeedometerState state) {
              final String message = state.errorMessage ?? 'GPS unavailable';
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            },
            builder: (BuildContext context, SpeedometerState state) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Column(
                  children: <Widget>[
                    _Header(state: state),
                    if (state.status != SpeedometerStatus.ready)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _StatusBanner(state: state),
                      ),
                    Expanded(
                      child: Center(
                        child: SpeedGauge(
                          speed: state.displaySpeed,
                          maxSpeed: state.unit.gaugeMax,
                          majorTicks: state.unit.gaugeMajorTicks,
                          limit: state.displayLimit,
                          limitEnabled: state.limitEnabled,
                          isOverLimit: state.isOverLimit,
                          unitLabel: state.unit.label,
                          decimals: state.unit.decimals,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    UnitSelector(
                      selected: state.unit,
                      onChanged:
                          (unit) => context.read<SpeedometerBloc>().add(
                            SpeedometerUnitChanged(unit: unit),
                          ),
                    ),
                    const SizedBox(height: 12),
                    _ControlBar(state: state),
                    const SizedBox(height: 12),
                    StatsPanel(state: state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final SpeedometerState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: <Color>[
                AppColors.primary.withValues(alpha: 0.26),
                AppColors.secondary.withValues(alpha: 0.18),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: const Icon(
            Icons.speed_rounded,
            color: AppColors.primary,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'SPEEDOMETER',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Live GPS speed',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.3,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        _LiveBadge(
          live: state.isLive,
          tracking: state.isTracking,
          onTap:
              () => context.read<SpeedometerBloc>().add(
                const SpeedometerTrackingToggled(),
              ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({
    required this.live,
    required this.tracking,
    required this.onTap,
  });

  final bool live;
  final bool tracking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool active = live && tracking;
    final String label = !live ? 'GPS OFF' : (tracking ? 'LIVE' : 'PAUSED');
    final Color color = active ? AppColors.success : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color:
              active
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.surfaceAlt,
          border: Border.all(
            color:
                active
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state});

  final SpeedometerState state;

  @override
  Widget build(BuildContext context) {
    final SpeedometerBloc bloc = context.read<SpeedometerBloc>();

    final (
      String message,
      String actionLabel,
      VoidCallback? action,
    ) = switch (state.status) {
      SpeedometerStatus.locationDisabled => (
        'Turn on location services to read your speed.',
        'TURN ON',
        () => bloc.add(const SpeedometerSettingsOpened()),
      ),
      SpeedometerStatus.permissionDenied => (
        'Location permission is needed to measure speed.',
        'ALLOW',
        () => bloc.add(const SpeedometerPermissionRequested()),
      ),
      SpeedometerStatus.permissionDeniedForever => (
        'Location is blocked. Enable it in system settings.',
        'SETTINGS',
        () => bloc.add(const SpeedometerSettingsOpened()),
      ),
      SpeedometerStatus.failure => (
        state.errorMessage ?? 'GPS is unavailable right now.',
        'RETRY',
        () => bloc.add(const SpeedometerPermissionRequested()),
      ),
      _ => ('', '', null),
    };

    if (message.isEmpty || action == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.location_off_rounded,
            size: 17,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: action,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({required this.state});

  final SpeedometerState state;

  @override
  Widget build(BuildContext context) {
    final SpeedometerBloc bloc = context.read<SpeedometerBloc>();

    return Row(
      children: <Widget>[
        Expanded(child: _LimitButton(state: state)),
        const SizedBox(width: 10),
        _SquareButton(
          icon:
              state.soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
          accent: state.soundEnabled ? AppColors.success : AppColors.textMuted,
          active: state.soundEnabled,
          tooltip: 'Alert sound',
          onTap:
              () => bloc.add(
                SpeedometerSoundToggled(enabled: !state.soundEnabled),
              ),
        ),
        const SizedBox(width: 10),
        _SquareButton(
          icon: Icons.restart_alt_rounded,
          accent: AppColors.textSecondary,
          active: false,
          tooltip: 'Reset trip',
          onTap: () => bloc.add(const SpeedometerTripReset()),
        ),
      ],
    );
  }
}

class _LimitButton extends StatelessWidget {
  const _LimitButton({required this.state});

  final SpeedometerState state;

  @override
  Widget build(BuildContext context) {
    final bool armed = state.limitEnabled;
    final Color accent = armed ? AppColors.warning : AppColors.textMuted;

    return GestureDetector(
      onTap: () => showSpeedLimitSheet(context),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                armed
                    ? AppColors.warning.withValues(alpha: 0.45)
                    : AppColors.border,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.tune_rounded, size: 18, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'SPEED LIMIT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${state.displayLimit.round()} ${state.unit.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color:
                          armed
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.accent,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: active ? accent.withValues(alpha: 0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? accent.withValues(alpha: 0.45) : AppColors.border,
            ),
          ),
          child: Icon(icon, size: 20, color: accent),
        ),
      ),
    );
  }
}
