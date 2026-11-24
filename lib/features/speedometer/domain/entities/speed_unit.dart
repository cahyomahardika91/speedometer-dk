/// Units the speedometer can display.
///
/// Speeds are always stored in metres per second (what the GPS reports) and
/// converted only for presentation, so switching units never changes the
/// physical values a trip has recorded.
enum SpeedUnit {
  kilometersPerHour(
    code: 'kmh',
    label: 'km/h',
    name: 'Kilometers per hour',
    factorFromMetersPerSecond: 3.6,
    decimals: 0,
    gaugeMax: 240,
    gaugeMajorTicks: 8,
    minLimit: 10,
    maxLimit: 240,
    limitStep: 5,
    presets: <double>[30, 50, 80, 120],
  ),
  metersPerSecond(
    code: 'ms',
    label: 'm/s',
    name: 'Meters per second',
    factorFromMetersPerSecond: 1,
    decimals: 1,
    gaugeMax: 60,
    gaugeMajorTicks: 6,
    minLimit: 3,
    maxLimit: 60,
    limitStep: 1,
    presets: <double>[5, 10, 15, 20],
  ),
  milesPerHour(
    code: 'mph',
    label: 'mph',
    name: 'Miles per hour',
    factorFromMetersPerSecond: 2.2369362920544,
    decimals: 0,
    gaugeMax: 160,
    gaugeMajorTicks: 8,
    minLimit: 5,
    maxLimit: 160,
    limitStep: 5,
    presets: <double>[20, 30, 50, 70],
  );

  const SpeedUnit({
    required this.code,
    required this.label,
    required this.name,
    required this.factorFromMetersPerSecond,
    required this.decimals,
    required this.gaugeMax,
    required this.gaugeMajorTicks,
    required this.minLimit,
    required this.maxLimit,
    required this.limitStep,
    required this.presets,
  });

  /// Stable identifier used for persistence.
  final String code;

  /// Short label shown in the UI (`km/h`, `m/s`, `mph`).
  final String label;

  /// Human readable name.
  final String name;

  /// Multiplier applied to a value in metres per second.
  final double factorFromMetersPerSecond;

  /// Decimal places used when displaying speeds in this unit.
  final int decimals;

  /// Top of the gauge scale, in this unit.
  final double gaugeMax;

  /// Number of labelled segments on the gauge.
  final int gaugeMajorTicks;

  /// Lowest speed limit that can be armed, in this unit.
  final double minLimit;

  /// Highest speed limit that can be armed, in this unit.
  final double maxLimit;

  /// Step used by the limit slider, in this unit.
  final double limitStep;

  /// Quick picks offered in the limit sheet, in this unit.
  final List<double> presets;

  /// Converts a value in metres per second to this unit.
  double toDisplay(double metersPerSecond) =>
      metersPerSecond * factorFromMetersPerSecond;

  /// Converts a value in this unit back to metres per second.
  double fromDisplay(double value) => value / factorFromMetersPerSecond;

  /// Speed value formatted with this unit's precision.
  String format(double metersPerSecond) =>
      toDisplay(metersPerSecond).toStringAsFixed(decimals);

  /// Rounds a value in this unit to the nearest slider step.
  double roundToStep(double value) => (value / limitStep).round() * limitStep;

  /// Number of divisions for the limit slider.
  int get limitDivisions => ((maxLimit - minLimit) / limitStep).round();

  static SpeedUnit fromCode(String? code) {
    return values.firstWhere(
      (SpeedUnit unit) => unit.code == code,
      orElse: () => SpeedUnit.kilometersPerHour,
    );
  }
}
