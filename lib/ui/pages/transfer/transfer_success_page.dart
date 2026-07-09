
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:lottie/lottie.dart';

class TransferSuccessPage extends StatelessWidget {
  const TransferSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
          'assets/json/Animation - 1713277247146.json', // Path to your Lottie animation file
          height: 300,
          width: 300,repeat: false
          // onLoaded: (composition) {
          //   // Once the animation is loaded, start a timer to navigate to the next screen after a delay
          //   Timer(Duration(seconds: 5), () {
          //     Navigator.of(context).pushReplacementNamed(
          //       '/home'
          //     );
          //   });
          // },
        ),
            Text(
              'Transfer Successful',
              style: blackTextStyle.copyWith(
                fontSize: 20,
                fontWeight: semiBold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 26,
            ),
            Text(
              'Use the money wisely and\ngrow our finance',
              style: greyTextStyle.copyWith(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 50,
            ),
            CustomFilledButton(
              width: 200,
              title: 'Back To Home',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
