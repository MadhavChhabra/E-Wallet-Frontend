import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/pages/forgotPassword/change_password.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:pinput/pinput.dart';

class VerifyOTP extends StatefulWidget {
  final String recievedEmail;
  const VerifyOTP({Key? key, required this.recievedEmail}) : super(key: key);

  @override
  State<VerifyOTP> createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool showError = false;

  Future<void> verifyOTP(String otp, String email) async {
    try {
      final response = await HttpService.postWithoutAuth(
          '/auth/password-reset/verify', {'email': email, 'otp': otp});
      if (!mounted) return;
      if (response['message'] == 'Success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('OTP Verified!'),
        ));
        Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => ChangePassword(
                  email: email,
                  otp: otp,
                ))));
      } else {
        setState(() => showError = true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message']?.toString() ??
              'Invalid or expired code. Please try again.'),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred while verifying OTP'),
      ));
    }
  }

  Future<void> resendOTP(String email) async {
    try {
      final response = await HttpService.postWithoutAuth(
          '/auth/password-reset/request', {'email': email});
      if (!mounted) return;
      if (response['message'] == 'Success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('OTP Sent Again!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error Sending OTP.'),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred while sending OTP'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String recievedEmail = widget.recievedEmail;
    const length = 6;
    const borderColor = Color.fromRGBO(114, 178, 238, 1);
    const errorColor = Color.fromRGBO(255, 234, 238, 1);
    const fillColor = Color.fromRGBO(222, 231, 240, .57);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Verification',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text('Enter the code sent to email',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                Text(recievedEmail, style: const TextStyle(fontSize: 18)),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  height: 68,
                  child: Pinput(
                    length: length,
                    controller: controller,
                    focusNode: focusNode,
                    defaultPinTheme: defaultPinTheme,
                    onCompleted: (pin) {
                      verifyOTP(pin, recievedEmail);
                    },
                    focusedPinTheme: defaultPinTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: borderColor),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      decoration: BoxDecoration(
                        color: errorColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: showError,
                  child: const Text(
                    'Invalid OTP. Please try again.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text('Didn\'t recieve a code?',
                    style: TextStyle(color: Colors.grey)),
                CustomFilledButton(
                  title: 'Resend OTP',
                  onPressed: () {
                    resendOTP(recievedEmail);
                    // Add logic to resend OTP
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
