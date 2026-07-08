/// Central app configuration.
///
/// The backend host is supplied at build/run time so no environment-specific
/// URL is hard-coded into the app:
///
///   flutter run --dart-define=API_BASE_URL=https://api.your-domain.com
///
/// Defaults target the Android emulator loopback (10.0.2.2 -> host machine's
/// localhost). Use `http://localhost:8080` for web/desktop, or your machine's
/// LAN IP for a physical device. Production builds should always use HTTPS.
class SharedValues {
  /// Scheme + host + port of the backend, e.g. `https://api.example.com`.
  static const String apiHost = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  /// Base URL for the versioned REST API.
  static const String baseUrl = '$apiHost/api/v1';

  /// Password-reset endpoints live under the auth namespace on the backend.
  static const String baseForgot = '$baseUrl/auth/password-reset';

  /// Razorpay public *test* key id (safe to ship in the client). Provide via
  ///   --dart-define=RAZORPAY_KEY_ID=rzp_test_xxxxxxxx
  /// The server still returns the key id in the order response; this is only a
  /// fallback for early wiring.
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );
}
