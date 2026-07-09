import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/transfer/payment_processing_screen.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_success_card.dart';

/// Legacy route — forwards to [PaymentProcessingScreen] without the debug title.
class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PaymentProcessingScreen(
      nextPage: const TransferSuccessCard(),
      message: 'Processing card payment…',
    );
  }
}
