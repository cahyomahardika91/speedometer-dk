import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/speed_unit.dart';

/// Segmented control for `km/h`, `m/s` and `mph`.
class UnitSelector extends StatelessWidget {
  const UnitSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final SpeedUnit selected;
  final ValueChanged<SpeedUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children:
            SpeedUnit.values.map((SpeedUnit unit) {
              final bool isSelected = unit == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(unit),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: isSelected ? AppGradients.primary : null,
                      boxShadow:
                          isSelected
                              ? <BoxShadow>[
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      unit.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isSelected
                                ? AppColors.background
                                : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
