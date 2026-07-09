import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/payment_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';

/// Razorpay wallet top-up entry screen — shows the user's real wallet details
/// before continuing to the amount + checkout flow.
class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  String? _iban;
  String _displayName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final user = await SharedUser().getCurrentUser();
      final iban = await PaymentService.primaryWalletIban();
      if (!mounted) return;
      setState(() {
        _iban = iban;
        _displayName = user != null
            ? '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim()
            : '';
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 40),
          Text(
            'Add money via Razorpay',
            style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (_iban == null)
            Text(
              'Add a wallet account first, then return here to top up.',
              style: greyTextStyle.copyWith(fontSize: 14),
            )
          else
            Row(
              children: [
                Image.asset('assets/img_wallet.png', width: 80),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _iban!,
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: semiBold,
                        ),
                      ),
                      if (_displayName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(_displayName, style: greyTextStyle.copyWith(fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 40),
          Text(
            'Secure payment',
            style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
          ),
          const SizedBox(height: 8),
          Text(
            'You will be redirected to Razorpay Checkout (test mode) to add funds to your wallet.',
            style: greyTextStyle.copyWith(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          CustomFilledButton(
            title: 'Continue',
            onPressed: _iban == null
                ? null
                : () {
                    Navigator.pushNamed(context, '/topup-amount');
                  },
          ),
        ],
      ),
    );
  }
}
