import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/payment_receipt.dart';
import 'package:flutter_ewallet/models/wallet_account.dart';
import 'package:flutter_ewallet/services/payment_service.dart';
import 'package:flutter_ewallet/services/razorpay/razorpay_checkout.dart';
import 'package:flutter_ewallet/services/wallet_account_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_dropdown_field.dart';
import 'package:flutter_ewallet/ui/widgets/numeric_keypad.dart';
import 'package:flutter_ewallet/ui/widgets/payment_success_screen.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:flutter_ewallet/utils/shared_values.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TopUpAmountPage extends StatefulWidget {
  const TopUpAmountPage({super.key, this.initialIban});

  final String? initialIban;

  @override
  State<TopUpAmountPage> createState() => _TopUpAmountPageState();
}

class _TopUpAmountPageState extends State<TopUpAmountPage> {
  final TextEditingController amountController =
      TextEditingController(text: '0');

  final RazorpayCheckout _checkout = RazorpayCheckout();
  bool _processing = false;
  bool _loadingWallets = true;
  String? _walletIban;
  List<WalletAccount> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  @override
  void dispose() {
    _checkout.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _loadWallets() async {
    try {
      final accounts =
          await WalletAccountService.instance.fetchAccounts(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _loadingWallets = false;
        if (widget.initialIban != null &&
            accounts.any((a) => a.iban == widget.initialIban)) {
          _walletIban = widget.initialIban;
        } else if (accounts.isNotEmpty) {
          _walletIban = accounts.first.iban;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingWallets = false);
    }
  }

  WalletAccount? get _selectedAccount {
    if (_walletIban == null) return null;
    for (final a in _accounts) {
      if (a.iban == _walletIban) return a;
    }
    return null;
  }

  Future<void> _startCheckout() async {
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount < 1) {
      _toast('Please enter an amount of at least Rs 1');
      return;
    }
    if (_walletIban == null) {
      _toast('Choose a wallet to top up');
      return;
    }

    setState(() => _processing = true);
    try {
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
        onSuccess: (result) => _handlePaymentSuccess(amount, result),
        onError: (message) => _toast(message),
      );
    } catch (e) {
      _toast(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _handlePaymentSuccess(
    double amount,
    RazorpayResult result,
  ) async {
    try {
      final verify = await PaymentService.verifyPayment(
        orderId: result.orderId,
        paymentId: result.paymentId,
        signature: result.signature,
      );
      AppEvents.instance.notifyWalletChanged();
      if (!mounted) return;

      final wallet = _selectedAccount;
      final receipt = PaymentReceipt(
        headline: 'Top-up successful',
        amount: amount,
        completedAt: DateTime.now(),
        counterpartyLabel: wallet?.label ?? _walletIban,
        referenceId: verify['transactionId']?.toString() ?? result.paymentId,
        subtitle: 'Credited via Razorpay',
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => PaymentSuccessScreen(receipt: receipt)),
        (_) => false,
      );
    } catch (e) {
      _toast('Payment captured but verification failed: ${_friendlyError(e)}');
    }
  }

  void _toast(String message) => Fluttertoast.showToast(msg: message);

  String _friendlyError(Object e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    return msg.isEmpty ? 'Something went wrong' : msg;
  }

  void _addAmount(String number) {
    if (amountController.text == '0') amountController.text = '';
    setState(() => amountController.text = amountController.text + number);
  }

  void _deleteAmount() {
    if (amountController.text.isNotEmpty) {
      setState(() {
        amountController.text =
            amountController.text.substring(0, amountController.text.length - 1);
        if (amountController.text.isEmpty) amountController.text = '0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: darkBackgroundColor,
        foregroundColor: whiteColor,
        title: const Text('Top up wallet'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            if (_loadingWallets)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else if (_accounts.isEmpty)
              Text(
                'Add a wallet account before topping up.',
                style: whiteTextStyle.copyWith(fontSize: 14),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CustomDropDownFieldButton<String>(
                title: 'Top up wallet',
                value: _walletIban,
                items: _accounts
                    .map((a) => DropdownMenuItem(
                          value: a.iban,
                          child: Text(a.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _walletIban = value);
                  if (value != null) {
                    WalletAccountService.instance.setPreferredIban(value);
                  }
                },
              ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Amount',
                  style: whiteTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: greyColor.withOpacity(0.4)),
                    ),
                  ),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: amountController,
                    builder: (_, value, __) => Text(
                      '₹ ${value.text}',
                      style: whiteTextStyle.copyWith(
                        fontSize: 40,
                        fontWeight: semiBold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              NumericKeypad(onDigit: _addAmount, onDelete: _deleteAmount),
              const SizedBox(height: 32),
              _processing
                  ? const Center(child: CircularProgressIndicator())
                  : CustomFilledButton(
                      title: 'Pay with Razorpay',
                      onPressed: _startCheckout,
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
