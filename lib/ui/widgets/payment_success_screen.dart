import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/payment_receipt.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/utils/shared.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

/// Rich success screen with amount, counterparty, and timestamp.
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.receipt,
    this.lottieAsset = 'assets/json/Animation - 1713277247146.json',
  });

  final PaymentReceipt receipt;
  final String lottieAsset;

  @override
  Widget build(BuildContext context) {
    final timeStr =
        DateFormat("MMMM dd, yyyy 'at' hh:mm a").format(receipt.completedAt);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Lottie.asset(
                lottieAsset,
                height: 220,
                width: 220,
                repeat: false,
              ),
              const SizedBox(height: 16),
              Text(
                receipt.headline,
                style: blackTextStyle.copyWith(
                  fontSize: 22,
                  fontWeight: semiBold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _ReceiptRow(
                label: 'Amount',
                value: formatCurrency(receipt.amount),
                emphasized: true,
              ),
              if (receipt.counterpartyLabel != null) ...[
                const SizedBox(height: 12),
                _ReceiptRow(
                  label: receipt.headline.contains('Top') ? 'Wallet' : 'To',
                  value: receipt.counterpartyLabel!,
                ),
              ],
              if (receipt.walletLabel != null) ...[
                const SizedBox(height: 12),
                _ReceiptRow(label: 'From', value: receipt.walletLabel!),
              ],
              const SizedBox(height: 12),
              _ReceiptRow(label: 'Date & time', value: timeStr),
              if (receipt.referenceId != null) ...[
                const SizedBox(height: 12),
                _ReceiptRow(label: 'Reference', value: receipt.referenceId!),
              ],
              if (receipt.subtitle != null) ...[
                const SizedBox(height: 16),
                Text(
                  receipt.subtitle!,
                  style: greyTextStyle.copyWith(fontSize: 14, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              CustomFilledButton(
                title: 'Back to home',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (_) => false,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: greyTextStyle.copyWith(fontSize: 14),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: blackTextStyle.copyWith(
              fontSize: emphasized ? 18 : 14,
              fontWeight: emphasized ? semiBold : medium,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
