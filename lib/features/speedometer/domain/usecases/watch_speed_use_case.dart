import '../entities/speed_sample.dart';
import '../repositories/location_repository.dart';

class WatchSpeedUseCase {
  const WatchSpeedUseCase(this._repository);

  final LocationRepository _repository;

  Stream<SpeedSample> call() => _repository.watchSpeed();
}
