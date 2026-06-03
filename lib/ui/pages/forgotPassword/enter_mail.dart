import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/forgotPassword/verify_otp.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../../utils/shared_values.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> verifyEmail(BuildContext context, String email) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
          Uri.parse('${SharedValues.baseForgot}/verifyMail/$email'));
      print(response.body.toString());
      if (response.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => VerifyOTP(recievedEmail: email),
        ));
      } else if (response.statusCode == 409) {
        Fluttertoast.showToast(msg: 'OTP Already Sent');
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => VerifyOTP(recievedEmail: email),
        ));
      } else {
        Fluttertoast.showToast(msg: 'Email does not exist!');
      }
    } catch (e) {
      print('Error verifying email: $e');
      // Show a generic error message
      Fluttertoast.showToast(
          msg: 'An error occurred while verifying email');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Image.asset('assets/forgot_send_mail.png', height: 331),
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 24),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Forgot Password',
                          style: blackTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: semiBold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 26,
                        ),
                        CustomTextField(
                          title: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        CustomFilledButton(
                          title: 'Send OTP',
                          onPressed: () {
                            verifyEmail(context, emailController.text);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _isLoading
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
