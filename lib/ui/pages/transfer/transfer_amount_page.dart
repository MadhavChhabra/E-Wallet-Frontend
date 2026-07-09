import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/pages/transfer/loading_animation_screen.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/numeric_keypad.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class TransferAmountPage extends StatefulWidget {
  final String fromIban;
  final String toIban;
  final String description;

  const TransferAmountPage({
    Key? key,
    required this.fromIban,
    required this.toIban,
    required this.description,
  }) : super(key: key);

  @override
  State<TransferAmountPage> createState() => _TransferAmountPageState();
}

class _TransferAmountPageState extends State<TransferAmountPage> {
  final TextEditingController amountController =
      TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();

    amountController.addListener(
      () {
        final text = amountController.text;
        final number = int.tryParse(text.replaceAll(RegExp(r'[.,]'), ''));

        if (number != null) {
          final formattedText = number.toString();
          setState(() {
            amountController.value = amountController.value.copyWith(
              text: formattedText,
              selection: TextSelection.collapsed(offset: formattedText.length),
            );
          });
        }
      },
    );
  }

  Future<void> sendTransferData(String fromIban, String toIban, String balance,
      String description) async {
    final amount = double.tryParse(balance);
    if (amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final transferData = {
      'fromBankAccountIban': fromIban,
      'toBankAccountIban': toIban,
      'amount': amount,
      'typeId': 1,
      'description': description,
    };

    try {
      final response = await HttpService.postWithAuth(
          '/bank-accounts/transfer', transferData);

      if (!mounted) return;
      if (response['message'] == 'Success') {
        AppEvents.instance.notifyWalletChanged();
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => const LoadingAnimationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response['message']?.toString() ?? 'Transfer failed'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void addAmount(String number) {
    if (amountController.text == '0') {
      amountController.text = '';
    }
    setState(() {
      amountController.text = amountController.text + number;
    });
  }

  void deleteAmount() {
    if (amountController.text.isNotEmpty) {
      setState(() {
        amountController.text = amountController.text
            .substring(0, amountController.text.length - 1);
        if (amountController.text == '') {
          amountController.text = '0';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          children: [
            Center(
              child: Text(
                'Total Amount',
                style: whiteTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: semiBold,
                ),
              ),
            ),
            const SizedBox(
              height: 48,
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: greyColor.withOpacity(0.4))),
                ),
                child: Text(
                  '₹ ${amountController.text}',
                  style:
                      whiteTextStyle.copyWith(fontSize: 40, fontWeight: semiBold),
                ),
              ),
            ),
            const SizedBox(
              height: 48,
            ),
            NumericKeypad(
              onDigit: addAmount,
              onDelete: deleteAmount,
            ),
            const SizedBox(
              height: 40,
            ),
            CustomFilledButton(
              title: 'Checkout Now',
              onPressed: () async {
                await sendTransferData(
                  widget.fromIban,
                  widget.toIban,
                  amountController.text,
                  widget.description,
                );
              },
            ),
            const SizedBox(
              height: 25,
            ),
            CustomTextButton(
              title: 'Term & Conditions',
              onPressed: () {},
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  // final Uri _url = Uri.parse('https://demo.midtrans.com/');

  // Future<void> _launchUrl() async {
  //   if (await Navigator.pushNamed(context, '/pin') == true) {
  //     Navigator.pushNamedAndRemoveUntil(
  //         context, '/transfer-success', (route) => false);
  //   }
  // }
}
