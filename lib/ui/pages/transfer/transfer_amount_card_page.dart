import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/services/payment_service.dart';
import 'package:flutter_ewallet/ui/pages/transfer/loading_card.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/numeric_keypad.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class TransferCardAmountPage extends StatefulWidget {
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvv;
  final String toIban;

  const TransferCardAmountPage({
    super.key,
    required this.toIban,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvv,
  });

  @override
  State<TransferCardAmountPage> createState() => _TransferCardAmountPageState();
}

class _TransferCardAmountPageState extends State<TransferCardAmountPage> {
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

  Future<void> sendTransferData(
    String cardHolderName,
    String toIban,
    String amount,
    String description,
    String cvv,
    String cardNumber,
    String expiry,
  ) async {
    // The backend models money movement as wallet-to-wallet transfers by IBAN.
    // A "card payment" here is settled from the user's primary wallet to the
    // recipient IBAN; the entered card is a UI affordance only.
    final fromIban = await PaymentService.primaryWalletIban();
    if (fromIban == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a wallet account first')),
      );
      return;
    }

    final transferData = {
      'fromBankAccountIban': fromIban,
      'toBankAccountIban': toIban,
      'amount': amount,
      'description': description,
      'typeId': 1,
    };

    try {
      final response =
          await HttpService.postWithAuth('/bank-accounts/transfer', transferData);

      if (!mounted) return;
      if (response['message'] == 'Success') {
        AppEvents.instance.notifyWalletChanged();
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LoadingCard()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message']?.toString() ?? 'Transfer failed')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending transfer')),
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
                    widget.cardHolderName,
                    widget.toIban,
                    amountController.text,
                    "Card Transfer",
                    widget.cvv,
                    widget.cardNumber,
                    widget.expiryDate);
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
}
