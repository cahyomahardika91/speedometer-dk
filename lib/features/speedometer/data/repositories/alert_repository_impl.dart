import '../../../../core/services/beep_player.dart';
import '../../domain/repositories/alert_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  const AlertRepositoryImpl(this._player);

  final BeepPlayer _player;

  @override
  Future<void> playBeep() => _player.play();
}
