import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/wallet_account.dart';
import 'package:flutter_ewallet/services/wallet_account_service.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_amount_page.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_dropdown_field.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class SelfTransferPage extends StatefulWidget {
  const SelfTransferPage({super.key});

  @override
  State<SelfTransferPage> createState() => _SelfTransferPageState();
}

class _SelfTransferPageState extends State<SelfTransferPage> {
  String? selectedFromIban;
  String? selectedToIban;
  bool _loading = true;
  List<WalletAccount> _accounts = [];

  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts =
          await WalletAccountService.instance.fetchAccounts(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _loading = false;
        if (accounts.isNotEmpty && selectedFromIban == null) {
          selectedFromIban = accounts.first.iban;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<DropdownMenuItem<String>> _toItems() {
    return _accounts
        .where((a) => a.iban != selectedFromIban)
        .map((a) => DropdownMenuItem(
              value: a.iban,
              child: Text(a.label),
            ))
        .toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Move between wallets')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 12),
                Text(
                  'Transfer between your own accounts.',
                  style: greyTextStyle.copyWith(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 20),
                CustomDropDownFieldButton<String>(
                  title: 'From',
                  value: selectedFromIban,
                  items: _accounts
                      .map((a) => DropdownMenuItem(
                            value: a.iban,
                            child: Text(a.label),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedFromIban = value;
                    if (selectedToIban == value) selectedToIban = null;
                  }),
                ),
                const SizedBox(height: 16),
                CustomDropDownFieldButton<String>(
                  title: 'To',
                  value: selectedToIban,
                  items: _toItems(),
                  onChanged: (value) => setState(() => selectedToIban = value),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  title: 'Note (optional)',
                  hintText: 'What is this for?',
                  controller: descriptionController,
                ),
                const SizedBox(height: 32),
                CustomFilledButton(
                  title: 'Enter amount',
                  onPressed: () {
                    if (selectedFromIban == null || selectedToIban == null) {
                      _showError('Choose both accounts.');
                      return;
                    }
                    if (selectedFromIban == selectedToIban) {
                      _showError('Source and destination must differ.');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransferAmountPage(
                          fromIban: selectedFromIban!,
                          toIban: selectedToIban!,
                          description: descriptionController.text,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
