import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/payment_receipt.dart';
import 'package:flutter_ewallet/ui/widgets/payment_success_screen.dart';

class TopUpSuccessPage extends StatelessWidget {
  const TopUpSuccessPage({super.key, this.receipt});

  final PaymentReceipt? receipt;

  @override
  Widget build(BuildContext context) {
    return PaymentSuccessScreen(
      receipt: receipt ??
          PaymentReceipt(
            headline: 'Top-up successful',
            amount: 0,
            completedAt: DateTime.now(),
          ),
    );
  }
}
