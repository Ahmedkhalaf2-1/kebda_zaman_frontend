import 'package:audioplayers/audioplayers.dart';

/// Abstraction over "play the order bell", so [AdminOrderAlertNotifier]
/// depends on neither `audioplayers` nor a real platform audio device
/// directly and can be tested with a fake.
abstract class AdminAlertSoundPlayer {
  /// Plays the bell once at [volume] (0.0-1.0, an application-level gain on
  /// the decoded asset — never an attempt to change the device/OS output
  /// volume). Returns `true` if playback actually started, `false` if it
  /// was blocked (e.g. a browser's autoplay restriction) or otherwise
  /// failed — the caller must not retry a `false` result silently in a
  /// loop, only in response to an explicit user action.
  ///
  /// A call while a previous chime from this same player is still sounding
  /// is a no-op returning `true` (already ringing) — this is what prevents
  /// overlapping playback instances.
  Future<bool> playOnce({required double volume});

  /// Stops any in-progress playback immediately (logout/account switch).
  Future<void> stop();
}

/// Real implementation backed by `audioplayers`. The bell asset
/// (`assets/sounds/order_bell.wav`) is an original synthesized chime — see
/// `assets/sounds/README.md` for how it was generated and its license
/// status (public-domain-equivalent, no third-party rights).
class AudioplayersAdminAlertSoundPlayer implements AdminAlertSoundPlayer {
  static const String _assetPath = 'sounds/order_bell.wav';

  /// Matches the synthesized asset's actual length (~2.28s) plus a small
  /// safety margin, so the no-overlap guard releases right as playback
  /// naturally ends. `onPlayerComplete` exists on `AudioPlayer` too, but
  /// its firing is inconsistent across the web/desktop backends this
  /// feature must run on, whereas a fixed timer matching a fixed, known
  /// asset is exact and platform-independent.
  static const Duration _chimeDuration = Duration(milliseconds: 2450);

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _releaseModeSet = false;

  Future<void> _ensureReleaseMode() async {
    if (_releaseModeSet) return;
    _releaseModeSet = true;
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  @override
  Future<bool> playOnce({required double volume}) async {
    if (_isPlaying) return true;
    try {
      await _ensureReleaseMode();
      await _player.stop();
      await _player.play(
        AssetSource(_assetPath),
        volume: volume.clamp(0.0, 1.0),
      );
      _isPlaying = true;
      Future<void>.delayed(_chimeDuration, () => _isPlaying = false);
      return true;
    } catch (_) {
      // Most commonly a browser autoplay rejection (Chrome blocks audio
      // until a user gesture unlocks the page) — surfaced to the caller as
      // "blocked" rather than thrown, so it can show an explicit "Enable
      // order sound" action instead of failing silently or retry-looping.
      _isPlaying = false;
      return false;
    }
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    try {
      await _player.stop();
    } catch (_) {
      // Nothing to stop, or the platform player is already gone — either
      // way there is nothing left to do.
    }
  }
}
