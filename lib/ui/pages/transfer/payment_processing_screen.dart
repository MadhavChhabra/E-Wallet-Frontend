import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:lottie/lottie.dart';

/// Full-screen payment processing animation (no debug-style app bar title).
class PaymentProcessingScreen extends StatelessWidget {
  const PaymentProcessingScreen({
    super.key,
    required this.nextPage,
    this.message = 'Processing payment…',
  });

  final Widget nextPage;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/json/loading.json',
                height: 220,
                width: 220,
                onLoaded: (_) {
                  Timer(const Duration(seconds: 2), () {
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => nextPage),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
