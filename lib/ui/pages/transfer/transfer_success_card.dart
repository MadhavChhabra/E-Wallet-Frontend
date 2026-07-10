
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/payment_receipt.dart';
import 'package:flutter_ewallet/ui/widgets/payment_success_screen.dart';

class TransferSuccessCard extends StatelessWidget {
  const TransferSuccessCard({super.key, this.receipt});

  final PaymentReceipt? receipt;

  @override
  Widget build(BuildContext context) {
    return PaymentSuccessScreen(
      receipt: receipt ??
          PaymentReceipt(
            headline: 'Payment successful',
            amount: 0,
            completedAt: DateTime.now(),
          ),
      lottieAsset: 'assets/json/card_success.json',
    );
  }
}
