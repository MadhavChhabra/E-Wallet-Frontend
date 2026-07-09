import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/utils/api_config.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _demoLoading = false;
  bool _signingIn = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// One-click demo: provisions a pre-populated account server-side and lands
  /// the visitor on a filled dashboard.
  Future<void> _startDemo() async {
    if (ApiConfig.isMisconfigured) {
      _showDemoError(
        'Demo backend is not configured. Set the API_BASE_URL GitHub Actions variable and redeploy.',
      );
      return;
    }

    setState(() => _demoLoading = true);
    try {
      final response = await HttpService.postWithoutAuth('/auth/demo', {});
      final data = response['data'];
      final token = data is Map ? data['token'] : null;
      if (response['message'] == 'Success' && token != null && token.toString().isNotEmpty) {
        SharedUser().updateLoggedInState(true);
        await SharedUser().writeToStorage('token', token);
        await SharedUser().writeToStorage('refreshToken', data['refreshToken']);
        await SharedUser().writeToStorage('user', jsonEncode(data));
        SharedUser().clearCachedUser();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        _showDemoError();
      }
    } catch (_) {
      _showDemoError();
    } finally {
      if (mounted) setState(() => _demoLoading = false);
    }
  }

  void _showDemoError([String? message]) {
    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: message ?? 'Demo is unavailable right now. Please try again.',
      ),
    );
  }

  Future<void> signIn() async {
    if (_signingIn) return;

    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('Please enter both your username and password.');
      return;
    }

    setState(() => _signingIn = true);

    try {
      final response = await HttpService.postWithoutAuth('/auth/login', {
        'username': username,
        'password': password,
      });

      final data = response['data'];
      final token = data is Map ? data['token'] : null;
      final refreshToken = data is Map ? data['refreshToken'] : null;

      if (token != null && token.toString().isNotEmpty) {
        await SharedUser().updateLoggedInState(true);
        await SharedUser().writeToStorage('token', token);
        await SharedUser().writeToStorage('refreshToken', refreshToken);
        await SharedUser().writeToStorage('user', jsonEncode(data));
        SharedUser().clearCachedUser();
      }

      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        snackBarPosition: SnackBarPosition.bottom,
        dismissType: DismissType.onSwipe,
        dismissDirection: const [DismissDirection.horizontal],
        const CustomSnackBar.success(message: 'Log In Successful!'),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      _showError(
        e.toString().replaceFirst('Exception: ', '').isNotEmpty
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Something went wrong. Please check your credentials and try again.',
      );
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      snackBarPosition: SnackBarPosition.bottom,
      dismissType: DismissType.onSwipe,
      dismissDirection: const [DismissDirection.horizontal],
      CustomSnackBar.error(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/img_logo_light.png',
                width: 155,
                height: 50,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Welcome back',
              style: blackTextStyle.copyWith(
                fontSize: 26,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to manage your wallet, transfers, and cards.',
              style: greyTextStyle.copyWith(fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomTextField(
                    hintText: 'Enter Username',
                    title: 'Username',
                    controller: usernameController,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    hintText: 'Enter Password',
                    title: 'Password',
                    obscureText: true,
                    controller: passwordController,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgotPasswordEnterMail');
                      },
                      child: Text(
                        'Forgot Password',
                        style: blueTextStyle.copyWith(fontWeight: medium),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _signingIn
                      ? SizedBox(
                          height: 52,
                          child: Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: purpleColor,
                              ),
                            ),
                          ),
                        )
                      : CustomFilledButton(
                          title: 'Sign In',
                          onPressed: signIn,
                        ),
                  const SizedBox(height: 14),
                  _demoLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        )
                      : OutlinedButton(
                          onPressed: _startDemo,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            side: BorderSide(color: purpleColor.withOpacity(0.45)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(56),
                            ),
                          ),
                          child: Text(
                            'Explore Live Demo',
                            style: TextStyle(
                              color: purpleColor,
                              fontWeight: semiBold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                  const SizedBox(height: 14),
                  const GoogleSignInButton(),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: Divider(color: greyColor.withOpacity(0.35))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: greyTextStyle.copyWith(fontSize: 13)),
                      ),
                      Expanded(child: Divider(color: greyColor.withOpacity(0.35))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextButton(
                    title: 'Create New Account',
                    onPressed: () {
                      Navigator.pushNamed(context, '/sign-up');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
