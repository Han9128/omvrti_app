
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
   /// Check if device supports biometrics (face/fingerprint)
  Future<bool> isBiometricAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isSupported = await _auth.isDeviceSupported();

    return canCheck && isSupported;
  }

  /// Authenticate user using biometrics (Face ID / Fingerprint)
  Future<bool> authenticateUser() async {
    try {
      final isAvailable = await isBiometricAvailable();

      if (!isAvailable) return false;

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: true, // only face/fingerprint (no PIN)
          stickyAuth: true,    // keeps auth active if app goes background briefly
        ),
      );

      return didAuthenticate;
    } catch (e) {
      // You can log error if needed
      return false;
    }
  }


}