import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:flutter_ewallet/utils/iban.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/user_model.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final nameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> saveBankAccount() async {
    if (_saving) return;
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter an account name');
      return;
    }

    setState(() => _saving = true);
    try {
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user == null) {
        Fluttertoast.showToast(msg: 'Please sign in again');
        return;
      }

      // A new account starts empty; the account number (IBAN) is generated for
      // the user — just like a real wallet. Fund it via transfer or top-up.
      final response = await HttpService.postWithAuth('/bank-accounts', {
        'name': name,
        'iban': generateIban(),
        'balance': 0,
        'userId': user.id,
      });

      if (response['message'] == 'Success') {
        AppEvents.instance.notifyWalletChanged();
        Fluttertoast.showToast(msg: 'Account linked');
        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(
            msg: response['message']?.toString() ?? 'Could not create account');
      }
    } catch (e) {
      // Surface the real reason (duplicate name, validation, session, etc.)
      Fluttertoast.showToast(
          msg: e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link a bank account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/add_bank.png', height: 240),
              const SizedBox(height: 12),
              Text(
                'Link a bank account',
                style: blackTextStyle.copyWith(fontSize: 20, fontWeight: semiBold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Give it a nickname. We’ll add it as a linked account you can send from, receive into, and top up.',
                style: greyTextStyle.copyWith(fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: nameController,
                title: 'Account nickname',
                hintText: 'e.g. HDFC Savings',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 28),
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : CustomFilledButton(
                      onPressed: saveBankAccount,
                      title: 'Link account',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
