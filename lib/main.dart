import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/navigation.dart';
import 'package:flutter_ewallet/ui/pages/qr_code_scanner.dart';
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
import 'package:flutter_ewallet/ui/pages/transaction_detail_page.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_page.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_success_page.dart';
import 'package:flutter_ewallet/ui/pages/BankAccount/add_account.dart';
import 'package:flutter_ewallet/ui/pages/ID_Card/add_id_card.dart';

import 'package:flutter_ewallet/ui/widgets/web_phone_shell.dart';
import 'package:flutter_ewallet/utils/api_config.dart';
import 'package:flutter_ewallet/utils/session_guard.dart';
import 'package:flutter_ewallet/utils/theme.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SessionGuard.navigatorKey = rootNavigatorKey;
  await ApiConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          WebPhoneShell(child: child ?? const SizedBox.shrink()),
      theme: buildAppTheme(),
      title: 'E-Wallet',
      routes: {
        '/': (context) => const SplashPage(),
        '/onboarding': (context) => const OnBoardingPage(),
        '/sign-in': (context) => const SignInPage(),
        '/sign-up': (context) => const SignUpPage(),
        '/sign_up_succes': (context) => const SignUpSuccesPage(),
        '/home': (context) => const CustomBottomNavigation(),
        '/profile': (context) => const ProfilePage(),
        '/pin': (context) => const PinPage(),
        '/profile-edit': (context) => const EditProfilePage(),
        '/profile-image-edit': (context) => const EditProfileImagePage(),
        '/profile-edit-success': (context) => const ProfileSuccesPage(),
        '/edit-pin': (context) => const EditProfilePinPage(),
        '/topup': (context) => const TopUpPage(),
        '/topup-amount': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return TopUpAmountPage(
            initialIban: args is String ? args : null,
          );
        },
        '/topup-success': (context) => const TopUpSuccessPage(),
        '/transfer': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return TransferPage(
            receiverIban: args is String ? args : null,
          );
        },
        '/selfTransfer': (context) => const SelfTransferPage(),
        '/transfer-success': (context) => const TransferSuccessPage(),
        '/accounts': (context) => const AccountsWidget(),
        '/addAccount': (context) => const AddAccountPage(),
        '/addCard': (context) => const AddCardPage(),
        '/selectCard': (context) => const SelectCard(),
        '/addIDCard': (context) => const IdCardUploadPage(),
        '/transactionHistory': (context) => const TransactionHistoryPage(),
        '/transaction-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final id = args is int ? args : int.tryParse('$args');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid transaction')),
            );
          }
          return TransactionDetailPage(transactionId: id);
        },
        '/showAccountQR': (context) => const QRCodeGenerator(),
        '/QR_Scanner': (context) => const QrScannerScreen(),
        '/cardPayment': (context) => const CardPaymentPage(),
        '/forgotPasswordEnterMail': (context) => const ForgotPasswordPage(),
      },
    );
  }
}
