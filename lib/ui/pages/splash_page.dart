import 'dart:async';

import 'package:flutter/foundation.dart';
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

    Timer(const Duration(seconds: 2), () {
      _checkLoginStatus();

      // Navigator.pushNamedAndRemoveUntil(
      //     context, '/onboarding', (route) => false);
    });
  }

  Future<bool> _authenticateWithBiometrics() async {
    // Biometrics aren't available on web (and may be absent on some devices);
    // don't block the session on it.
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
