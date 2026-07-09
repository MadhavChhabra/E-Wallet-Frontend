import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Authenticated ("internal") password change for a logged-in user. Requires the
/// current password and revokes other sessions on success.
class ChangePasswordInternal extends StatelessWidget {
  final String email;
  const ChangePasswordInternal({Key? key, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController repeatPasswordController =
        TextEditingController();

    Future<void> changePassword(
        String currentPassword, String newPassword) async {
      if (newPassword.length < 6) {
        Fluttertoast.showToast(msg: 'Password must be at least 6 characters');
        return;
      }
      try {
        final response = await HttpService.putWithAuth(
          '/users/me/change-password',
          {'currentPassword': currentPassword, 'newPassword': newPassword},
        );

        if (response['message'] == 'Success') {
          Fluttertoast.showToast(msg: 'Password changed Successfully!');
          // Sessions were revoked server-side; sign the user out locally too.
          await SharedUser.logout();
          if (!context.mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/sign-in', (route) => false);
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
          const SizedBox(height: 120),
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
                    const SizedBox(height: 12),
                    CustomTextField(
                      title: 'Current Password',
                      controller: currentPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      title: 'New Password',
                      controller: newPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      title: 'Repeat Password',
                      controller: repeatPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    CustomFilledButton(
                      title: 'Update Now',
                      onPressed: () {
                        final String currentPassword =
                            currentPasswordController.text;
                        final String newPassword = newPasswordController.text;
                        final String repeatPassword =
                            repeatPasswordController.text;

                        if (newPassword == repeatPassword) {
                          changePassword(currentPassword, newPassword);
                        } else {
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
