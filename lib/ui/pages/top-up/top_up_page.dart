import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/user_model.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/web_safe_scaffold.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  List<dynamic> _accounts = [];
  String? _selectedIban;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user == null) {
        throw Exception('Sign in to top up your wallet');
      }

      final response =
          await HttpService.getWithAuth('/bank-accounts/users/${user.id}');
      final data = response['data'];
      final accounts = data is List ? data : <dynamic>[];

      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _selectedIban = accounts.isNotEmpty
            ? accounts.first['iban']?.toString()
            : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebSafeScaffold(
      title: 'Top Up',
      body: RefreshIndicator(
        onRefresh: _loadAccounts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 24),
            Text(
              'Choose wallet',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
            ),
            const SizedBox(height: 8),
            Text(
              'Funds are credited to the account you select after Razorpay confirms payment.',
              style: greyTextStyle.copyWith(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_error != null)
              _ErrorState(message: _error!, onRetry: _loadAccounts)
            else if (_accounts.isEmpty)
              _ErrorState(
                message: 'Add a wallet account before topping up.',
                onRetry: () => Navigator.pushNamed(context, '/addAccount'),
                actionLabel: 'Add account',
              )
            else
              ..._accounts.map(_buildAccountTile),
            const SizedBox(height: 24),
            if (!_loading && _accounts.isNotEmpty)
              CustomFilledButton(
                title: 'Continue',
                onPressed: _selectedIban == null
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          '/topup-amount',
                          arguments: _selectedIban,
                        );
                      },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTile(dynamic account) {
    final iban = account['iban']?.toString() ?? '';
    final name = account['name']?.toString() ?? 'Wallet';
    final balance = (account['balance'] as num?)?.toDouble() ?? 0;
    final selected = _selectedIban == iban;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => _selectedIban = iban),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: selected
                  ? LinearGradient(
                      colors: [purpleColor, blueColor.withOpacity(0.85)],
                    )
                  : null,
              color: selected ? null : whiteColor,
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : purpleColor.withOpacity(0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: (selected ? purpleColor : blackColor).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: (selected ? whiteColor : purpleColor).withOpacity(0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: selected ? whiteColor : purpleColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: (selected ? whiteTextStyle : blackTextStyle)
                            .copyWith(fontWeight: semiBold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        iban,
                        style: (selected ? whiteTextStyle : greyTextStyle)
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${balance.toStringAsFixed(2)}',
                  style: (selected ? whiteTextStyle : blackTextStyle)
                      .copyWith(fontWeight: semiBold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    this.actionLabel = 'Retry',
  });

  final String message;
  final VoidCallback onRetry;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(message, style: greyTextStyle, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
