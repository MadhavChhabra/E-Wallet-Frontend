import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ChangePassword extends StatelessWidget {
  final String email;
  final String otp;
  const ChangePassword({Key? key, required this.email, required this.otp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController repeatPasswordController =
        TextEditingController();

    Future<void> changePassword(String email, String newPassword) async {
      if (newPassword.length < 6) {
        Fluttertoast.showToast(msg: 'Password must be at least 6 characters');
        return;
      }
      try {
        final response = await HttpService.postWithoutAuth(
          '/auth/password-reset/confirm',
          {'email': email, 'otp': otp, 'newPassword': newPassword},
        );

        if (response['message'] == 'Success') {
          Fluttertoast.showToast(msg: 'Password changed Successfully!');
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
              context, '/sign-in', (route) => false);
        } else {
          Fluttertoast.showToast(
              msg: response['message']?.toString() ??
                  'Error occurred, please try again later');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error occurred, please try again later');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(
            height: 150,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: whiteColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    CustomTextField(
                      title: 'New Password',
                      controller: newPasswordController,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    CustomTextField(
                      title: 'Repeat Password',
                      controller: repeatPasswordController,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomFilledButton(
                      title: 'Update Now',
                      onPressed: () {
                        final String newPassword = newPasswordController.text;
                        final String repeatPassword =
                            repeatPasswordController.text;

                        if (newPassword == repeatPassword) {
                          // Passwords match, proceed to change password
// Get the user's email here
                          changePassword(email, newPassword);
                        } else {
                          // Passwords don't match, show error message
                          Fluttertoast.showToast(msg: 'Passwords don\'t match');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
