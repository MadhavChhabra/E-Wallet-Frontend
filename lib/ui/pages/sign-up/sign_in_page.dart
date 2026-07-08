import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/utils/api_config.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:http/http.dart' as http;
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
    final url = '${ApiConfig.baseUrl}/auth/login';
    final username = usernameController.text.trim();
    final password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        SharedUser().updateLoggedInState(true);
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];
        final token = data['token'];
        final refreshToken = data['refreshToken'];

        if (token != null && token.isNotEmpty) {
          SharedUser().writeToStorage('token', token);
          SharedUser().writeToStorage('refreshToken', refreshToken);
          SharedUser().writeToStorage('user', jsonEncode(data));
        }

        showTopSnackBar(
          Overlay.of(context),
          snackBarPosition: SnackBarPosition.bottom,
          dismissType: DismissType.onSwipe,
          dismissDirection: [DismissDirection.horizontal],
          const CustomSnackBar.success(
            message: 'Log In Successful!',
          ),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        showTopSnackBar(
          Overlay.of(context),
          snackBarPosition: SnackBarPosition.bottom,
          dismissType: DismissType.onSwipe,
          dismissDirection: [DismissDirection.horizontal],
          const CustomSnackBar.error(
            message:
                'Something went wrong. Please check your credentials and try again',
          ),
        );
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 100),
          Image.asset(
            'assets/img_logo_light.png',
            width: 155,
            height: 50,
          ),
          const SizedBox(height: 30),
          Text(
            'Sign In &\nGrow Your Finance',
            style: blackTextStyle.copyWith(
              fontSize: 20,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: whiteColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextField(
                  hintText: "Enter Username",
                  title: 'Username',
                  controller: usernameController,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "Enter Password",
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
                      style: blueTextStyle,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomFilledButton(
                  title: 'Sign In',
                  onPressed: signIn,
                ),
                const SizedBox(height: 10),
                // One-click demo — no signup needed; lands on a filled dashboard.
                _demoLoading
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ))
                    : CustomTextButton(
                        title: '🚀 Explore Live Demo',
                        onPressed: _startDemo,
                      ),
                const SizedBox(height: 10),
                
                // GoogleSignInWidget()
                const GoogleSignInButton(),
                                const SizedBox(height: 10),

                const Center(
                    child: Text(
                  "Or",
                  style: TextStyle(color: Colors.grey),
                )),
                const SizedBox(
                  height: 10,
                ),


                CustomTextButton(
                  title: 'Create New Account',
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign-up');
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
