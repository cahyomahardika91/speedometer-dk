import '../repositories/alert_repository.dart';

class PlayAlertUseCase {
  const PlayAlertUseCase(this._repository);

  final AlertRepository _repository;

  Future<void> call() => _repository.playBeep();
}
