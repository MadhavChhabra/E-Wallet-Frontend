import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/widgets/animated_entrance.dart';
import 'package:flutter_ewallet/ui/widgets/custom_input_pin_button.dart';
import 'package:flutter_ewallet/ui/widgets/web_safe_scaffold.dart';
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
      return '111111';
    } else {
      return pin;
    }
  }

  addPin(String number) async {
    if (pinController.text.length < 6) {
      setState(() {
        pinController.text = pinController.text + number;
      });
    }

    if (pinController.text.length == 6) {
      if (pinController.text.length == 6 &&
          pinController.text == await getPin()) {
        Navigator.pop(context, true);
      } else {
        showCustomSnackBar(context, 'Wrong PIN. Please Try Again');
      }
    }
  }

  deletePin() {
    if (pinController.text.isNotEmpty) {
      setState(() {
        pinController.text =
            pinController.text.substring(0, pinController.text.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebSafeScaffold(
      title: 'Enter PIN',
      backgroundColor: darkBackgroundColor,
      appBarBackgroundColor: darkBackgroundColor,
      appBarForegroundColor: whiteColor,
      body: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final topInset = (height * 0.08).clamp(24.0, 72.0);
            final titleGap = (height * 0.055).clamp(28.0, 56.0);
            final keypadGap = (height * 0.045).clamp(24.0, 48.0);
            final bottomInset = (height * 0.06).clamp(20.0, 48.0);
            final keypadSpacing = (height * 0.028).clamp(28.0, 40.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 58),
              child: Column(
                children: [
                  SizedBox(height: topInset),
                  AnimatedEntrance(
                    child: Text(
                      'Enter PIN',
                      style: whiteTextStyle.copyWith(
                        fontSize: 20,
                        fontWeight: semiBold,
                      ),
                    ),
                  ),
                  SizedBox(height: titleGap),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 80),
                    child: SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: pinController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        cursorColor: greyColor,
                        enabled: false,
                        style: whiteTextStyle.copyWith(
                          fontSize: 36,
                          fontWeight: medium,
                          letterSpacing: 16,
                        ),
                        decoration: InputDecoration(
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: greyColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: keypadGap),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: AnimatedEntrance(
                        delay: const Duration(milliseconds: 140),
                        offsetY: 24,
                        child: Wrap(
                          spacing: keypadSpacing,
                          runSpacing: keypadSpacing,
                          alignment: WrapAlignment.center,
                          children: [
                            CustomInputPinButton(
                              text: '1',
                              onTap: () => addPin('1'),
                            ),
                            CustomInputPinButton(
                              text: '2',
                              onTap: () => addPin('2'),
                            ),
                            CustomInputPinButton(
                              text: '3',
                              onTap: () => addPin('3'),
                            ),
                            CustomInputPinButton(
                              text: '4',
                              onTap: () => addPin('4'),
                            ),
                            CustomInputPinButton(
                              text: '5',
                              onTap: () => addPin('5'),
                            ),
                            CustomInputPinButton(
                              text: '6',
                              onTap: () => addPin('6'),
                            ),
                            CustomInputPinButton(
                              text: '7',
                              onTap: () => addPin('7'),
                            ),
                            CustomInputPinButton(
                              text: '8',
                              onTap: () => addPin('8'),
                            ),
                            CustomInputPinButton(
                              text: '9',
                              onTap: () => addPin('9'),
                            ),
                            const SizedBox(height: 60, width: 60),
                            CustomInputPinButton(
                              text: '0',
                              onTap: () => addPin('0'),
                            ),
                            PressScale(
                              onTap: deletePin,
                              scale: 0.92,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: numberBackgroundColor,
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: bottomInset),
                ],
              ),
            );
          },
        ),
    );
  }
}
