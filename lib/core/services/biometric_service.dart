import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The kind of biometric the device currently exposes, collapsed down to
/// what the UI actually needs to decide on a label/icon — never the raw
/// [BiometricType] list, which callers shouldn't have to interpret.
enum KZBiometricKind { face, fingerprint, generic, none }

/// Outcome of a single [BiometricService.authenticate] call. A sealed result
/// rather than a bool + exception so callers can map every case to a
/// localized message without ever touching a raw platform exception string.
sealed class BiometricAuthResult {
  const BiometricAuthResult();
}

class BiometricAuthSuccess extends BiometricAuthResult {
  const BiometricAuthSuccess();
}

/// User cancelled the system prompt, or backgrounded the app during it.
class BiometricAuthCancelled extends BiometricAuthResult {
  const BiometricAuthCancelled();
}

/// No biometric hardware, or the device does not support it.
class BiometricAuthUnavailable extends BiometricAuthResult {
  const BiometricAuthUnavailable();
}

/// Hardware is present but the user has no biometrics enrolled.
class BiometricAuthNotEnrolled extends BiometricAuthResult {
  const BiometricAuthNotEnrolled();
}

/// Too many failed attempts — temporary cooldown.
class BiometricAuthLockedOut extends BiometricAuthResult {
  const BiometricAuthLockedOut();
}

/// Too many failed attempts — permanent, requires device credential reset.
class BiometricAuthPermanentlyLockedOut extends BiometricAuthResult {
  const BiometricAuthPermanentlyLockedOut();
}

/// Any other OS/platform authentication error — never surfaced verbatim.
class BiometricAuthError extends BiometricAuthResult {
  const BiometricAuthError();
}

/// Thin wrapper around `local_auth` — the only place in the app that talks
/// to the platform biometric APIs. Callers (Login screen, Settings, session
/// bootstrap) only ever see [KZBiometricKind] and [BiometricAuthResult].
class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  /// True when the device has usable biometric hardware AND at least one
  /// biometric is currently enrolled. This is the single check that should
  /// gate whether any biometric UI is shown at all.
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// The best single [KZBiometricKind] to represent in the UI (label/icon).
  /// Face wins when both are present, since that's the most specific
  /// available signal on most modern devices; anything else present but not
  /// classifiable falls back to a generic "biometric" wording.
  Future<KZBiometricKind> availableKind() async {
    try {
      final types = await _localAuth.getAvailableBiometrics();
      if (types.isEmpty) return KZBiometricKind.none;
      if (types.contains(BiometricType.face)) return KZBiometricKind.face;
      if (types.contains(BiometricType.fingerprint)) {
        return KZBiometricKind.fingerprint;
      }
      return KZBiometricKind.generic;
    } catch (_) {
      return KZBiometricKind.none;
    }
  }

  /// Prompts the OS biometric UI. `biometricOnly: true` — never falls back
  /// to device PIN/pattern/passcode, since the product requirement is
  /// specifically Face ID / Touch ID / fingerprint / device biometrics.
  Future<BiometricAuthResult> authenticate({required String reasonKey}) async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: reasonKey,
        authMessages: const [
          AndroidAuthMessages(),
          IOSAuthMessages(),
        ],
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return ok
          ? const BiometricAuthSuccess()
          : const BiometricAuthCancelled();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'NotAvailable':
          return const BiometricAuthUnavailable();
        case 'NotEnrolled':
          return const BiometricAuthNotEnrolled();
        case 'LockedOut':
          return const BiometricAuthLockedOut();
        case 'PermanentlyLockedOut':
          return const BiometricAuthPermanentlyLockedOut();
        default:
          return const BiometricAuthError();
      }
    } catch (_) {
      return const BiometricAuthError();
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});
