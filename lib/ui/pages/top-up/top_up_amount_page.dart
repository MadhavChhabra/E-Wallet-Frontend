import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/payment_service.dart';
import 'package:flutter_ewallet/services/razorpay/razorpay_checkout.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/numeric_keypad.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
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
          keyId: (order['keyId'] ?? SharedValues.razorpayKeyId).toString(),
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
      AppEvents.instance.notifyWalletChanged();
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
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          children: [
            Center(
              child: Text(
                'Total Amount',
                style: whiteTextStyle.copyWith(fontSize: 20, fontWeight: semiBold),
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: greyColor.withOpacity(0.4))),
                ),
                child: Text(
                  '₹ ${amountController.text}',
                  style:
                      whiteTextStyle.copyWith(fontSize: 40, fontWeight: semiBold),
                ),
              ),
            ),
            const SizedBox(height: 48),
            NumericKeypad(
              onDigit: _addAmount,
              onDelete: _deleteAmount,
            ),
            const SizedBox(height: 40),
            _processing
                ? const Center(child: CircularProgressIndicator())
                : CustomFilledButton(
                    title: 'Pay with Razorpay',
                    onPressed: _startCheckout,
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
