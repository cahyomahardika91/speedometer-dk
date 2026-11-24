import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The big number in the middle of the dial.
class DigitalSpeedDisplay extends StatelessWidget {
  const DigitalSpeedDisplay({
    super.key,
    required this.value,
    required this.unitLabel,
    required this.decimals,
    required this.size,
    required this.accent,
    required this.isOverLimit,
  });

  final double value;
  final String unitLabel;
  final int decimals;

  /// Diameter of the gauge, used to scale every measurement.
  final double size;
  final Color accent;
  final bool isOverLimit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          value.toStringAsFixed(decimals),
          maxLines: 1,
          style: TextStyle(
            fontSize: size * 0.29,
            height: 1.0,
            fontWeight: FontWeight.w700,
            letterSpacing: -size * 0.014,
            color: AppColors.textPrimary,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            shadows: <Shadow>[
              Shadow(
                color: accent.withValues(alpha: 0.55),
                blurRadius: size * 0.045,
              ),
            ],
          ),
        ),
        SizedBox(height: size * 0.012),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: size * 0.045,
              height: 1.5,
              color: accent.withValues(alpha: 0.7),
            ),
            SizedBox(width: size * 0.014),
            Text(
              unitLabel,
              style: TextStyle(
                fontSize: size * 0.05,
                fontWeight: FontWeight.w600,
                letterSpacing: size * 0.006,
                color: accent,
              ),
            ),
            SizedBox(width: size * 0.014),
            Container(
              width: size * 0.045,
              height: 1.5,
              color: accent.withValues(alpha: 0.7),
            ),
          ],
        ),
        SizedBox(height: size * 0.035),
        AnimatedOpacity(
          opacity: isOverLimit ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size * 0.028,
              vertical: size * 0.012,
            ),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.warning_amber_rounded,
                  size: size * 0.034,
                  color: AppColors.danger,
                ),
                SizedBox(width: size * 0.01),
                Text(
                  'LIMIT EXCEEDED',
                  style: TextStyle(
                    fontSize: size * 0.028,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
