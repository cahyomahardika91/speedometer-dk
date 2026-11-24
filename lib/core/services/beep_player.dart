import 'package:audioplayers/audioplayers.dart';

/// Plays the bundled alert tone, reusing one player so repeated beeps are
/// immediate and do not leak platform channels.
class BeepPlayer {
  BeepPlayer() : _player = AudioPlayer(playerId: 'speed-limit-alert');

  static const String _assetPath = 'sounds/beep.wav';

  final AudioPlayer _player;
  Future<void>? _warmUp;

  Future<void> play() async {
    try {
      _warmUp ??= _prepare();
      await _warmUp;
      await _player.stop();
      await _player.resume();
    } catch (_) {
      // Audio is a nicety: never let a failing speaker break the speedometer.
      _warmUp = null;
    }
  }

  Future<void> _prepare() async {
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setSource(AssetSource(_assetPath));
  }
}
