import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';

import '../../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfilePinPage extends StatelessWidget {
  const EditProfilePinPage({super.key});

  Future<String> getPin() async {
    String? pin = await SharedUser().getSecurityPin();
    if (pin == null) {
      return "111111";
    } else {
      return pin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController oldPinController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit PIN'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: whiteColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    CustomTextField(
                      title: 'Old PIN',
                      controller: oldPinController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(6)],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    CustomTextField(
                      title: 'New PIN',
                      controller: newPinController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(6)],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomFilledButton(
                      title: 'Update Now',
                      onPressed: () async {
                        final expected = await getPin();
                        if (!context.mounted) return;
                        if (oldPinController.text == expected) {
                          await SharedUser().setSecurityPin(newPinController.text);
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(context,
                              '/profile-edit-success', (route) => false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Old Pin is Incorrect")));
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
