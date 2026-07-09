import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/transfer/payment_processing_screen.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_success_page.dart';

/// Legacy route — forwards to [PaymentProcessingScreen] without the debug title.
class LoadingAnimationScreen extends StatelessWidget {
  const LoadingAnimationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaymentProcessingScreen(
      nextPage: const TransferSuccessPage(),
      message: 'Processing payment…',
    );
  }
}
