import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/payment_receipt.dart';
import 'package:flutter_ewallet/ui/widgets/payment_success_screen.dart';

/// Legacy route — prefer navigating with [PaymentSuccessScreen] directly.
class TransferSuccessPage extends StatelessWidget {
  const TransferSuccessPage({super.key, this.receipt});

  final PaymentReceipt? receipt;

  @override
  Widget build(BuildContext context) {
    return PaymentSuccessScreen(
      receipt: receipt ??
          PaymentReceipt(
            headline: 'Transfer successful',
            amount: 0,
            completedAt: DateTime.now(),
          ),
    );
  }
}
