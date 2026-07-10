import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/payment_receipt.dart';
import 'package:flutter_ewallet/ui/pages/transfer/payment_processing_screen.dart';
import 'package:flutter_ewallet/ui/widgets/payment_success_screen.dart';

/// Legacy route — forwards to [PaymentProcessingScreen] without the debug title.
class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PaymentProcessingScreen(
      nextPage: PaymentSuccessScreen(
        receipt: PaymentReceipt(
          headline: 'Payment successful',
          amount: 0,
          completedAt: DateTime.now(),
        ),
        lottieAsset: 'assets/json/card_success.json',
      ),
      message: 'Processing card payment…',
    );
  }
}
