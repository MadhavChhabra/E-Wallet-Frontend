import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:local_auth/local_auth.dart';

import '../../utils/RefreshToken.dart';
import '../../utils/shared_user.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _precacheAssets();
    Future<void>.delayed(const Duration(seconds: 2), _checkLoginStatus);
  }

  Future<void> _precacheAssets() async {
    if (!mounted) return;
    final assetPaths = [
      'assets/img_logo_dark.png',
      'assets/img_logo_light.png',
      'assets/placeholder_image.jpg',
      'assets/bankCardBackgrounds/bg1.jpg',
      'assets/bankCardBackgrounds/bg2.jpg',
    ];
    for (final path in assetPaths) {
      await precacheImage(AssetImage(path), context);
    }
  }

  Future<bool> _authenticateWithBiometrics() async {
    if (kIsWeb) return true;
    try {
      final LocalAuthentication auth = LocalAuthentication();
      if (!await auth.isDeviceSupported()) return true;
      return await auth.authenticate(
          options: const AuthenticationOptions(
            sensitiveTransaction: true,
            stickyAuth: true,
          ),
          localizedReason: 'Please authenticate to proceed');
    } catch (_) {
      // If biometrics fail/unavailable, fall through rather than trapping the user.
      return true;
    }
  }

  _checkLoginStatus() async {
    String? refreshToken = await SharedUser().getRefreshToken();
    if (refreshToken != null) {
      _isLoggedIn = true;
    }
    if (_isLoggedIn) {
      bool didAuthenticate = await _authenticateWithBiometrics();
      if (didAuthenticate) {
        await RefreshTokenButton.getAccessToken();

        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, '/onboarding', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      body: Center(
        child: Container(
          width: 155,
          height: 150,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img_logo_dark.png'),
            ),
          ),
        ),
      ),
    );
  }
}
