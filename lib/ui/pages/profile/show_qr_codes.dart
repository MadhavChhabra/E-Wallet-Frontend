import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/user_model.dart';
import '../../../services/http_service.dart';
import '../../../utils/shared_user.dart';

/// Receive money: shows a scannable QR (encoding the account IBAN) per linked
/// account, with a one-tap "copy account number" to share it any other way.
class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({super.key});

  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  List<String> ibans = [];
  List<String> names = [];
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _index = 0;
  bool _loading = true;
  String username = '';

  @override
  void initState() {
    super.initState();
    username =
        '${SharedUser().getFirstname() ?? ''} ${SharedUser().getLastname() ?? ''}'
            .trim();
    fetchUserBankAccounts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchUserBankAccounts() async {
    try {
      final UserModel? user = await SharedUser().getCurrentUser();
      final response =
          await HttpService.getWithAuth('/bank-accounts/users/${user?.id}');
      if (response['message'] == 'Success' && response['data'] is List) {
        final list = response['data'] as List;
        if (!mounted) return;
        setState(() {
          ibans = [for (final a in list) a['iban'].toString()];
          names = [for (final a in list) a['name'].toString()];
          _loading = false;
        });
        return;
      }
    } catch (_) {
      // fall through to empty state
    }
    if (mounted) setState(() => _loading = false);
  }

  String _masked(String iban) =>
      iban.length <= 8 ? iban : '${iban.substring(0, 4)} •••• ${iban.substring(iban.length - 4)}';

  void _copy(String iban) {
    Clipboard.setData(ClipboardData(text: iban));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account number copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive money')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : ibans.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Link a bank account to get a QR others can pay you with.',
                        style: greyTextStyle.copyWith(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(username.isEmpty ? 'Scan to pay me' : username,
                          style: blackTextStyle.copyWith(
                              fontSize: 18, fontWeight: semiBold)),
                      const SizedBox(height: 4),
                      Text('Show this QR to get paid instantly',
                          style: greyTextStyle.copyWith(fontSize: 13)),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: ibans.length,
                          onPageChanged: (i) => setState(() => _index = i),
                          itemBuilder: (context, index) =>
                              _card(ibans[index], names[index]),
                        ),
                      ),
                      if (ibans.length > 1) _dots(),
                      const SizedBox(height: 20),
                    ],
                  ),
      ),
    );
  }

  Widget _card(String iban, String name) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightBackgroundColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: QrImageView(
                data: iban,
                version: QrVersions.auto,
                size: 220,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: blackColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(name.toUpperCase(),
                style: blackTextStyle.copyWith(
                    fontWeight: semiBold, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(_masked(iban), style: greyTextStyle.copyWith(fontSize: 13)),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => _copy(iban),
              icon: const Icon(Icons.copy_rounded, size: 18),
              style: OutlinedButton.styleFrom(
                foregroundColor: purpleColor,
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: purpleColor.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              label: const Text('Copy account number'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        ibans.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: _index == i ? 18 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: _index == i ? purpleColor : purpleColor.withOpacity(0.25),
          ),
        ),
      ),
    );
  }
}
