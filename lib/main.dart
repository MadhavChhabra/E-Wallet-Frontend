import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/ID_Card/add_id_card.dart';
import 'package:flutter_ewallet/ui/pages/Navigation.dart';
import 'package:flutter_ewallet/ui/pages/QR_code_scanner.dart';
import 'package:flutter_ewallet/ui/pages/card/add_card_page.dart';
import 'package:flutter_ewallet/ui/pages/card/pick_a_card.dart';
import 'package:flutter_ewallet/ui/pages/card_payment_form.dart';
import 'package:flutter_ewallet/ui/pages/forgotPassword/enter_mail.dart';
import 'package:flutter_ewallet/ui/pages/profile/edit_profile_image.dart';
import 'package:flutter_ewallet/ui/pages/profile/edit_profile_page.dart';
import 'package:flutter_ewallet/ui/pages/profile/edit_profile_pin_page.dart';
import 'package:flutter_ewallet/ui/pages/home_page.dart';
import 'package:flutter_ewallet/ui/pages/onboarding_page.dart';
import 'package:flutter_ewallet/ui/pages/profile/show_qr_codes.dart';
import 'package:flutter_ewallet/ui/pages/profile/success_edit_profile.dart';
import 'package:flutter_ewallet/ui/pages/profile/profile_page.dart';
import 'package:flutter_ewallet/ui/pages/profile/pin_page.dart';
import 'package:flutter_ewallet/ui/pages/self_transfer_screen.dart';
import 'package:flutter_ewallet/ui/pages/sign-up/sign_up_page.dart';
import 'package:flutter_ewallet/ui/pages/sign-up/sign_up_succes.dart';
import 'package:flutter_ewallet/ui/pages/sign-up/sign_in_page.dart';
import 'package:flutter_ewallet/ui/pages/splash_page.dart';
import 'package:flutter_ewallet/ui/pages/top-up/top_up_amount_page.dart';
import 'package:flutter_ewallet/ui/pages/top-up/top_up_page.dart';
import 'package:flutter_ewallet/ui/pages/top-up/top_up_success.dart';
import 'package:flutter_ewallet/ui/pages/transaction_history.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_page.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_success_page.dart';
import 'package:flutter_ewallet/ui/pages/BankAccount/add_account.dart';

import 'package:flutter_ewallet/utils/theme.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: lightBackgroundColor,
          appBarTheme: AppBarTheme(
            backgroundColor: lightBackgroundColor,
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(color: blackColor),
            titleTextStyle: blackTextStyle.copyWith(
              fontSize: 20,
              fontWeight: semiBold,
            ),
          )),
      title: 'Flutter e-wallet',
      routes: {
        '/': (context) => const SplashPage(),
        '/onboarding': (context) => const OnBoardingPage(),
        '/sign-in': (context) => const SignInPage(),
        '/sign-up': (context) => const SignUpPage(),
        '/sign_up_succes': (context) => const SignUpSuccesPage(),
        '/home': (context) => CustomBottomNavigation(),
        '/profile': (context) => const ProfilePage(),
        '/pin': (context) => const PinPage(),
        '/profile-edit': (context) => const EditProfilePage(),
        '/profile-image-edit': (context) => const EditProfileImagePage(),
        '/profile-edit-success': (context) => const ProfileSuccesPage(),
        '/edit-pin': (context) => const EditProfilePinPage(),
        '/topup': (context) => const TopUpPage(),
        // '/topup-amount': (context) => const TopUpAmountPage(),
        '/topup-success': (context) => const TopUpSuccessPage(),
        '/transfer': (context) => const TransferPage(),
        '/selfTransfer': (context) => const SelfTransferPage(),
        // '/transfer-amount': (context) => const TransferAmountPage(),
        '/transfer-success': (context) => const TransferSuccessPage(),

        '/accounts': (context) => const AccountsWidget(),
        '/addAccount': (context) => const AddAccountPage(),
        '/addCard': (context) => const AddCardPage(),
        '/selectCard': (context) =>  const SelectCard(),
        '/addIDCard': (context) => const ID_CardUploadPage(),
        '/transactionHistory': (context) => const TransactionHistoryPage(),
        '/showAccountQR': (context) => const QRCodeGenerator(),
        '/QR_Scanner': (context) => const QrScannerScreen(),
        '/cardPayment':(context) =>  const CardPaymentPage(),
        '/forgotPasswordEnterMail':(context) =>   ForgotPasswordPage(),
        // '/forgotPasswordVerifyOTP':(context) =>   VerifyOTP(),
      },
    );
  }
}
