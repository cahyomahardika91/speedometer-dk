import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'digital_speed_display.dart';

/// Circular speedometer: gradient arc, tick scale, limit marker, needle and
/// the digital read-out in the middle.
class SpeedGauge extends StatefulWidget {
  const SpeedGauge({
    super.key,
    required this.speed,
    required this.maxSpeed,
    required this.majorTicks,
    required this.limit,
    required this.limitEnabled,
    required this.isOverLimit,
    required this.unitLabel,
    required this.decimals,
  });

  /// Current speed, already converted to [unitLabel].
  final double speed;
  final double maxSpeed;
  final int majorTicks;

  /// Armed limit, already converted to [unitLabel].
  final double limit;
  final bool limitEnabled;
  final bool isOverLimit;
  final String unitLabel;
  final int decimals;

  @override
  State<SpeedGauge> createState() => _SpeedGaugeState();
}

class _SpeedGaugeState extends State<SpeedGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isOverLimit) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SpeedGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOverLimit != oldWidget.isOverLimit) {
      if (widget.isOverLimit) {
        _pulse.repeat(reverse: true);
      } else {
        _pulse.stop();
        _pulse.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color get _accent {
    if (widget.isOverLimit) return AppColors.danger;
    if (widget.limitEnabled &&
        widget.limit > 0 &&
        widget.speed / widget.limit >= 0.85) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double boundedHeight =
            constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : constraints.maxWidth;
        final double size = math.min(constraints.maxWidth, boundedHeight);
        if (size <= 0) return const SizedBox.shrink();

        return SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: widget.speed),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, double animatedSpeed, _) {
              final double fraction = (animatedSpeed / widget.maxSpeed).clamp(
                0.0,
                1.0,
              );
              final double limitFraction = (widget.limit / widget.maxSpeed)
                  .clamp(0.0, 1.0);

              return AnimatedBuilder(
                animation: _pulse,
                builder: (BuildContext context, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GaugePainter(
                            fraction: fraction,
                            limitFraction: limitFraction,
                            limitEnabled: widget.limitEnabled,
                            isOverLimit: widget.isOverLimit,
                            pulse: _pulse.value,
                            maxSpeed: widget.maxSpeed,
                            majorTicks: widget.majorTicks,
                          ),
                        ),
                      ),
                      DigitalSpeedDisplay(
                        value: animatedSpeed,
                        unitLabel: widget.unitLabel,
                        decimals: widget.decimals,
                        size: size,
                        accent: _accent,
                        isOverLimit: widget.isOverLimit,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.fraction,
    required this.limitFraction,
    required this.limitEnabled,
    required this.isOverLimit,
    required this.pulse,
    required this.maxSpeed,
    required this.majorTicks,
  });

  /// Dial starts at 135° and sweeps 270° clockwise, leaving the bottom open.
  static const double _startAngle = math.pi * 0.75;
  static const double _sweepAngle = math.pi * 1.5;
  static const int _minorTicksPerMajor = 4;

  final double fraction;
  final double limitFraction;
  final bool limitEnabled;
  final bool isOverLimit;
  final double pulse;
  final double maxSpeed;
  final int majorTicks;

  Color get _accent {
    if (isOverLimit) return AppColors.danger;
    if (limitEnabled && limitFraction > 0 && fraction >= limitFraction * 0.85) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }

  List<Color> _arcColors() {
    if (isOverLimit) {
      return const <Color>[
        Color(0xFFF43F5E),
        Color(0xFFFB7185),
        Color(0xFFFBBF24),
      ];
    }
    if (limitEnabled && limitFraction > 0 && fraction >= limitFraction * 0.85) {
      return const <Color>[
        Color(0xFF22D3EE),
        Color(0xFFFBBF24),
        Color(0xFFFB923C),
      ];
    }
    return const <Color>[
      Color(0xFF22D3EE),
      Color(0xFF38BDF8),
      Color(0xFF818CF8),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2;
    if (radius <= 4) return;

    final double stroke = radius * 0.085;
    final double arcRadius = radius - stroke * 0.95;
    final Rect arcRect = Rect.fromCircle(center: center, radius: arcRadius);

    // Soft halo behind the dial, breathing while the limit is exceeded.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            _accent.withValues(alpha: 0.14 + pulse * 0.14),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Outer hairline ring.
    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.05),
    );

    // Track.
    canvas.drawArc(
      arcRect,
      _startAngle,
      _sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF14202F),
    );

    final double sweep = _sweepAngle * fraction;
    if (sweep > 0.002) {
      final List<Color> colors = _arcColors();

      final SweepGradient glow = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + _sweepAngle,
        colors: colors
            .map((Color color) => color.withValues(alpha: 0.28 + pulse * 0.3))
            .toList(growable: false),
        stops: const <double>[0.0, 0.55, 1.0],
      );

      canvas.drawArc(
        arcRect,
        _startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 1.15
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 0.9)
          ..shader = glow.createShader(arcRect),
      );

      canvas.drawArc(
        arcRect,
        _startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: _startAngle,
            endAngle: _startAngle + _sweepAngle,
            colors: colors,
            stops: const <double>[0.0, 0.55, 1.0],
          ).createShader(arcRect),
      );
    }

    _paintTicks(canvas, center, radius, arcRadius, stroke);
    _paintLimitMarker(canvas, center, arcRadius, stroke);
    _paintNeedle(canvas, center, radius, arcRadius, stroke);
  }

  void _paintTicks(
    Canvas canvas,
    Offset center,
    double radius,
    double arcRadius,
    double stroke,
  ) {
    final Paint minorPaint =
        Paint()
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.16);
    final Paint majorPaint =
        Paint()
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.5);

    final int totalMinor = majorTicks * _minorTicksPerMajor;
    final double ticksOuter = arcRadius - stroke * 1.0;

    for (int i = 0; i <= totalMinor; i++) {
      final bool isMajor = i % _minorTicksPerMajor == 0;
      final double angle = _startAngle + _sweepAngle * (i / totalMinor);
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      final double length = isMajor ? radius * 0.05 : radius * 0.026;

      canvas.drawLine(
        center + direction * ticksOuter,
        center + direction * (ticksOuter - length),
        isMajor ? majorPaint : minorPaint,
      );
    }

    final double labelRadius = ticksOuter - radius * 0.115;
    for (int i = 0; i <= majorTicks; i++) {
      final double t = i / majorTicks;
      final double angle = _startAngle + _sweepAngle * t;
      _paintText(
        canvas,
        center,
        angle,
        labelRadius,
        (maxSpeed * t).round().toString(),
        radius * 0.072,
      );
    }
  }

  void _paintLimitMarker(
    Canvas canvas,
    Offset center,
    double arcRadius,
    double stroke,
  ) {
    if (!limitEnabled || limitFraction <= 0) return;

    final double angle = _startAngle + _sweepAngle * limitFraction;
    final Offset direction = Offset(math.cos(angle), math.sin(angle));
    final Color color = isOverLimit ? AppColors.danger : AppColors.warning;

    final Paint marker =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = color;

    canvas.drawLine(
      center + direction * (arcRadius - stroke * 1.7),
      center + direction * (arcRadius + stroke * 0.55),
      marker,
    );
    canvas.drawCircle(
      center + direction * (arcRadius + stroke * 0.55),
      stroke * 0.22,
      Paint()..color = color,
    );
  }

  void _paintNeedle(
    Canvas canvas,
    Offset center,
    double radius,
    double arcRadius,
    double stroke,
  ) {
    final double angle = _startAngle + _sweepAngle * fraction;
    final Offset direction = Offset(math.cos(angle), math.sin(angle));
    final Offset perpendicular = Offset(-direction.dy, direction.dx);

    final double needleLength = arcRadius - stroke * 1.9;
    final Offset tip = center + direction * needleLength;
    final Offset base = center - direction * (radius * 0.03);
    final double halfWidth = radius * 0.018;

    final Path needle =
        Path()
          ..moveTo(
            base.dx + perpendicular.dx * halfWidth,
            base.dy + perpendicular.dy * halfWidth,
          )
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(
            base.dx - perpendicular.dx * halfWidth,
            base.dy - perpendicular.dy * halfWidth,
          )
          ..close();

    final Color needleColor =
        isOverLimit ? const Color(0xFFFFE4E8) : AppColors.textPrimary;

    canvas.drawPath(
      needle,
      Paint()
        ..color = _accent.withValues(alpha: 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.022),
    );

    canvas.drawPath(
      needle,
      Paint()
        ..shader = ui.Gradient.linear(center, tip, <Color>[
          needleColor.withValues(alpha: 0.45),
          needleColor,
        ]),
    );

    // Hub.
    canvas.drawCircle(
      center,
      radius * 0.085,
      Paint()..color = AppColors.surface,
    );
    canvas.drawCircle(
      center,
      radius * 0.085,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _accent.withValues(alpha: 0.85),
    );
    canvas.drawCircle(center, radius * 0.028, Paint()..color = _accent);
  }

  void _paintText(
    Canvas canvas,
    Offset center,
    double angle,
    double radius,
    String text,
    double fontSize,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Offset position =
        center + Offset(math.cos(angle), math.sin(angle)) * radius;
    painter.paint(
      canvas,
      position - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.limitFraction != limitFraction ||
        oldDelegate.limitEnabled != limitEnabled ||
        oldDelegate.isOverLimit != isOverLimit ||
        oldDelegate.pulse != pulse ||
        oldDelegate.maxSpeed != maxSpeed ||
        oldDelegate.majorTicks != majorTicks;
  }
}
