import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBiometricEnabledKey = 'biometric_login_enabled';
const _kSessionActiveKey = 'session_active';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // ── Device capability checks ───────────────────────────────────────────────

  /// Whether the device has biometric hardware (fingerprint sensor, Face ID, etc.)
  /// regardless of whether the user has enrolled any biometrics yet.
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Whether the device hardware supports biometrics AND the user has enrolled at least one.
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Human-readable label for the available biometric type.
  Future<String> getBiometricLabel() async {
    final types = await getAvailableBiometrics();
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
    if (types.contains(BiometricType.iris)) return 'Iris Scan';
    return 'Biometrics';
  }

  // ── User opt-in persistence ────────────────────────────────────────────────
  // Biometric login is only shown after a user explicitly enables it following
  // a successful email/password login. This prevents strangers from accessing
  // the app via biometrics on an unlocked device.

  /// Whether this user previously opted in to biometric login.
  Future<bool> isBiometricLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kBiometricEnabledKey) ?? false;
  }

  /// Call after successful email/password login when user accepts the prompt.
  Future<void> enableBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricEnabledKey, true);
  }

  /// Call when user disables biometric login from settings.
  Future<void> disableBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBiometricEnabledKey);
  }

  // ── Session persistence ────────────────────────────────────────────────────
  // A session flag is written on successful login and cleared on logout.
  // The login screen reads this on startup to decide whether to show the
  // login form or auto-trigger biometric (WhatsApp-style).

  Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSessionActiveKey) ?? false;
  }

  Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSessionActiveKey, true);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionActiveKey);
  }

  // ── Authentication ─────────────────────────────────────────────────────────

  /// Prompts the user to authenticate. Returns true on success.
  /// Falls back to device PIN/pattern when biometric fails (biometricOnly: false).
  Future<bool> authenticateUser({
    String reason = 'Authenticate to access OmVrti.ai',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allows PIN fallback if biometric fails
          stickyAuth: true,     // keeps auth alive if app briefly backgrounds
        ),
      );
    } catch (e) {
      debugPrint('BiometricService: auth error — $e');
      return false;
    }
  }

  /// Cancels an in-progress authentication prompt.
  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (_) {}
  }
}

// ── Riverpod providers ──────────────────────────────────────────────────────

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// True only when the device has biometrics AND the user previously opted in.
/// This is what drives the biometric button visibility on the login screen.
final biometricLoginEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  final optedIn = await service.isBiometricLoginEnabled();
  if (!optedIn) return false;
  return service.isBiometricAvailable();
});

/// Label for the biometric button ("Face ID", "Fingerprint", etc.).
final biometricLabelProvider = FutureProvider<String>((ref) {
  return ref.watch(biometricServiceProvider).getBiometricLabel();
});
