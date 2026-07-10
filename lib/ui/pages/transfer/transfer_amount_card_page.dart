import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/payment_receipt.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/services/payment_service.dart';
import 'package:flutter_ewallet/services/wallet_account_service.dart';
import 'package:flutter_ewallet/ui/pages/transfer/payment_processing_screen.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/numeric_keypad.dart';
import 'package:flutter_ewallet/ui/widgets/payment_success_screen.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:flutter_ewallet/utils/idempotency.dart';
import 'package:flutter_ewallet/utils/pin_gate.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class TransferCardAmountPage extends StatefulWidget {
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvv;
  final String toIban;

  const TransferCardAmountPage({
    super.key,
    required this.toIban,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvv,
  });

  @override
  State<TransferCardAmountPage> createState() => _TransferCardAmountPageState();
}

class _TransferCardAmountPageState extends State<TransferCardAmountPage> {
  final TextEditingController amountController =
      TextEditingController(text: '0');
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    amountController.addListener(_formatAmount);
  }

  @override
  void dispose() {
    amountController.removeListener(_formatAmount);
    amountController.dispose();
    super.dispose();
  }

  void _formatAmount() {
    final text = amountController.text;
    final number = int.tryParse(text.replaceAll(RegExp(r'[.,]'), ''));
    if (number != null) {
      final formattedText = number.toString();
      if (formattedText != text) {
        amountController.value = amountController.value.copyWith(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }
    }
  }

  Future<void> _checkout() async {
    final parsedAmount = double.tryParse(amountController.text);
    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final fromIban = await PaymentService.primaryWalletIban();
    if (fromIban == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a wallet account first')),
      );
      return;
    }

    final fromAccount =
        await WalletAccountService.instance.accountForIban(fromIban);
    if (fromAccount != null && parsedAmount > fromAccount.balance) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. Available: ₹${fromAccount.balance.toStringAsFixed(0)}',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    final pinOk = await requirePin(context);
    if (!pinOk || !mounted) return;

    setState(() => _submitting = true);

    final transferData = {
      'fromBankAccountIban': fromIban,
      'toBankAccountIban': widget.toIban,
      'amount': parsedAmount,
      'description': 'Wallet payment',
      'typeId': 1,
    };

    try {
      final response = await HttpService.postWithAuth(
        '/bank-accounts/transfer',
        transferData,
        idempotencyKey: newIdempotencyKey(),
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      if (response['message'] == 'Success') {
        AppEvents.instance.notifyWalletChanged();

        final toAccount =
            await WalletAccountService.instance.accountForIban(widget.toIban);
        final payeeLabel = toAccount?.label ??
            (widget.toIban.length > 4
                ? '…${widget.toIban.substring(widget.toIban.length - 4)}'
                : widget.toIban);

        final receipt = PaymentReceipt(
          headline: 'Payment successful',
          amount: parsedAmount,
          completedAt: DateTime.now(),
          counterpartyLabel: payeeLabel,
          walletLabel: fromAccount?.label,
          referenceId: response['data']?['id']?.toString(),
          subtitle: 'Paid from wallet · card ${widget.cardNumber}',
        );

        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentProcessingScreen(
              nextPage: PaymentSuccessScreen(
                receipt: receipt,
                lottieAsset: 'assets/json/card_success.json',
              ),
              message: 'Processing payment…',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? 'Payment failed'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending payment')),
      );
    }
  }

  void addAmount(String number) {
    if (amountController.text == '0') {
      amountController.text = '';
    }
    amountController.text = amountController.text + number;
  }

  void deleteAmount() {
    if (amountController.text.isNotEmpty) {
      amountController.text = amountController.text
          .substring(0, amountController.text.length - 1);
      if (amountController.text.isEmpty) {
        amountController.text = '0';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: darkBackgroundColor,
        foregroundColor: whiteColor,
        title: const Text('Enter amount'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Center(
              child: Text(
                'Total amount',
                style: whiteTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
            ),
            const SizedBox(height: 48),
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
            const SizedBox(height: 48),
            NumericKeypad(
              onDigit: addAmount,
              onDelete: deleteAmount,
            ),
            const SizedBox(height: 40),
            CustomFilledButton(
              title: _submitting ? 'Please wait…' : 'Confirm & pay',
              onPressed: _submitting ? null : _checkout,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
