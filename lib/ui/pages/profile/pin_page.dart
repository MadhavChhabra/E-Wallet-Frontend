import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/widgets/numeric_keypad.dart';
import 'package:flutter_ewallet/utils/shared.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class PinPage extends StatefulWidget {
  const PinPage({super.key});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final TextEditingController pinController = TextEditingController(text: '');

  Future<String> getPin() async {
    String? pin = await SharedUser().getSecurityPin();
    if (pin == null) {
      return "111111";
    } else {
      return pin;
    }
  }

  Future<void> addPin(String number) async {
    if (pinController.text.length < 6) {
      setState(() {
        pinController.text = pinController.text + number;
      });
    }

    if (pinController.text.length == 6) {
      final expected = await getPin();
      if (!mounted) return;
      if (pinController.text == expected) {
        Navigator.pop(context, true);
      } else {
        showCustomSnackBar(context, 'Wrong PIN. Please Try Again');
      }
    }
  }

  void deletePin() {
    if (pinController.text.isNotEmpty) {
      setState(() {
        pinController.text =
            pinController.text.substring(0, pinController.text.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter PIN',
                  style: whiteTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(
                  height: 56,
                ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: pinController,
                    obscureText: true,
                    obscuringCharacter: '*',
                    cursorColor: greyColor,
                    enabled: false,
                    textAlign: TextAlign.center,
                    style: whiteTextStyle.copyWith(
                      fontSize: 36,
                      fontWeight: medium,
                      letterSpacing: 12,
                    ),
                    decoration: InputDecoration(
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: greyColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 48,
                ),
                NumericKeypad(
                  onDigit: addPin,
                  onDelete: deletePin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
