import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../../utils/shared_values.dart';
import '../../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ChangePassword extends StatelessWidget {
  final String email;
  const ChangePassword({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController repeatPasswordController =
        TextEditingController();

    Future<void> changePassword(String email, String newPassword) async {
      try {
        final response = await http.post(
          Uri.parse('${SharedValues.baseForgot}/changePassword/$email'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'password': newPassword,
            'repeatPassword': newPassword,
          }),
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: 'Password changed Successfully!');

          Navigator.pushNamedAndRemoveUntil(
              context, '/sign-in', (route) => false);
        } else if (response.statusCode == 417) {
          Fluttertoast.showToast(msg: 'Please enter your password again');
        } else {
          // Handle other errors
          Fluttertoast.showToast(msg: 'Error occured, please try again later');
        }
      } catch (e) {
        // Handle any errors that occur during the request
        print('Error changing password: $e');
        // Show a generic error message
        Fluttertoast.showToast(msg: 'Error occured, please try again later');
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
