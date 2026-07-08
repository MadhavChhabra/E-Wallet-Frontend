import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/payment_service.dart';
import 'package:flutter_ewallet/services/razorpay/razorpay_checkout.dart';
import 'package:flutter_ewallet/utils/api_config.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/web_safe_scaffold.dart';
import 'package:flutter_ewallet/ui/widgets/custom_input_pin_button.dart';
import 'package:flutter_ewallet/utils/shared_values.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Wallet top-up via Razorpay.
///
/// Flow: enter an amount → the backend creates a Razorpay order → the Checkout
/// opens (native SDK on mobile, Razorpay JS on web) → on success the signed
/// result is verified server-side, which credits the wallet.
class TopUpAmountPage extends StatefulWidget {
  const TopUpAmountPage({super.key});

  @override
  State<TopUpAmountPage> createState() => _TopUpAmountPageState();
}

class _TopUpAmountPageState extends State<TopUpAmountPage> {
  final TextEditingController amountController =
      TextEditingController(text: '0');

  final RazorpayCheckout _checkout = RazorpayCheckout();
  bool _processing = false;
  String? _walletIban;

  @override
  void dispose() {
    _checkout.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _walletIban = args;
    }
  }

  Future<void> _startCheckout() async {
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount < 1) {
      _toast('Please enter an amount of at least Rs 1');
      return;
    }

    setState(() => _processing = true);
    try {
      _walletIban ??= await PaymentService.primaryWalletIban();
      if (_walletIban == null) {
        _toast('Add a wallet account before topping up');
        return;
      }

      final order = await PaymentService.createOrder(
        amount: amount,
        toBankAccountIban: _walletIban!,
      );

      _checkout.open(
        RazorpayOptions(
          keyId: (order['keyId'] ??
                  (ApiConfig.razorpayKeyId.isNotEmpty
                      ? ApiConfig.razorpayKeyId
                      : SharedValues.razorpayKeyId))
              .toString(),
          orderId: order['orderId'].toString(),
          amountInPaise: (order['amountInPaise'] as num).toInt(),
          currency: (order['currency'] ?? 'INR').toString(),
        ),
        onSuccess: _handlePaymentSuccess,
        onError: (message) => _toast(message),
      );
    } catch (e) {
      _toast(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _handlePaymentSuccess(RazorpayResult result) async {
    try {
      await PaymentService.verifyPayment(
        orderId: result.orderId,
        paymentId: result.paymentId,
        signature: result.signature,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/topup-success', (r) => false);
    } catch (e) {
      _toast('Payment captured but verification failed: ${_friendlyError(e)}');
    }
  }

  void _toast(String message) {
    Fluttertoast.showToast(msg: message);
  }

  String _friendlyError(Object e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    return msg.isEmpty ? 'Something went wrong' : msg;
  }

  void _addAmount(String number) {
    if (amountController.text == '0') {
      amountController.text = '';
    }
    setState(() => amountController.text = amountController.text + number);
  }

  void _deleteAmount() {
    if (amountController.text.isNotEmpty) {
      setState(() {
        amountController.text =
            amountController.text.substring(0, amountController.text.length - 1);
        if (amountController.text.isEmpty) {
          amountController.text = '0';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebSafeScaffold(
      title: 'Enter amount',
      backgroundColor: darkBackgroundColor,
      appBarBackgroundColor: darkBackgroundColor,
      appBarForegroundColor: whiteColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 58),
          children: [
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Total Amount',
                style: whiteTextStyle.copyWith(fontSize: 20, fontWeight: semiBold),
              ),
            ),
            const SizedBox(height: 50),
            Align(
              child: SizedBox(
                width: 220,
                child: TextFormField(
                  controller: amountController,
                  cursorColor: greyColor,
                  enabled: false,
                  style: whiteTextStyle.copyWith(fontSize: 32, fontWeight: medium),
                  decoration: InputDecoration(
                    prefixIcon: Text(
                      'Rs ',
                      style: whiteTextStyle.copyWith(fontSize: 32, fontWeight: medium),
                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: greyColor),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Wrap(
              spacing: 40,
              runSpacing: 40,
              children: [
                for (final n in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
                  CustomInputPinButton(text: n, onTap: () => _addAmount(n)),
                const SizedBox(height: 60, width: 60),
                CustomInputPinButton(text: '0', onTap: () => _addAmount('0')),
                GestureDetector(
                  onTap: _deleteAmount,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: numberBackgroundColor,
                    ),
                    child: Center(child: Icon(Icons.arrow_back, color: whiteColor)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            _processing
                ? const Center(child: CircularProgressIndicator())
                : CustomFilledButton(
                    title: 'Pay with Razorpay',
                    onPressed: _startCheckout,
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
