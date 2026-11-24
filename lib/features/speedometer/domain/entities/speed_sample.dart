import 'package:equatable/equatable.dart';

/// A single speed reading coming from the location stream.
class SpeedSample extends Equatable {
  const SpeedSample({required this.metersPerSecond, required this.timestamp});

  /// Speed in metres per second, never negative.
  final double metersPerSecond;

  /// Moment the reading was produced.
  final DateTime timestamp;

  @override
  List<Object?> get props => <Object?>[metersPerSecond, timestamp];
}
