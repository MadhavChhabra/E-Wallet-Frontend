// import 'package:flutter/services.dart';
// import 'package:local_auth/local_auth.dart';

// final localAuth = LocalAuthentication();

// Future<bool> _isBiometricAvailable() async {
//   bool canCheckBiometrics = false;
//   try {
//     canCheckBiometrics = await localAuth.canCheckBiometrics;
//   } on PlatformException catch (e) {
//     print(e);
//   }
//   return canCheckBiometrics;
// }

// Future<bool> _authenticateWithBiometrics() async {
//   bool didAuthenticate = false;
//   try {
//     didAuthenticate = await localAuth.authenticateWithBiometrics(
//       localizedReason: 'Please authenticate to access the app',
//       stickyAuth: false, // Don't force authentication on every app launch
//       useErrorDialogs: true, // Show informative error dialogs to users
//       biometricOnly: true, // Only allow biometric authentication (no pin/password fallback)
//       sensitiveTransaction: true, // Mark the authentication as sensitive
//     );
//   } on PlatformException catch (e) {
//     if (e.code == 'BiometryNotAvailable') {
//       print('Biometry is not available on the device.');
//     } else if (e.code == 'NotEnrolled') {
//       print('Biometry is not enrolled on the device.');
//     } else {
//       print(e);
//     }
//   }
//   return didAuthenticate;
// }
