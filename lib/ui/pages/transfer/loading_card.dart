import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_success_card.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Screen'),
      ),
      body: Center(
        child: Lottie.asset(
          'assets/json/loading.json', // Path to your Lottie animation file
          height: 300,
          width: 300,
          onLoaded: (composition) {
            // Once the animation is loaded, start a timer to navigate to the next screen after a delay
            Timer(const Duration(seconds: 2), () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: ((context) => const TransferSuccessCard()))
                // '/home'
              );
            });
          },
        ),
      ),
    );
  }
}

