import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/wallet_account.dart';
import 'package:flutter_ewallet/services/wallet_account_service.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_amount_page.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_dropdown_field.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/utils/iban_utils.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class TransferPage extends StatefulWidget {
  final String? receiverIban;
  const TransferPage({super.key, this.receiverIban});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  static const _customPayee = '__custom__';

  String? selectedFromIban;
  String? selectedToKey;
  bool _useCustomIban = false;
  bool _loading = true;

  List<WalletAccount> _accounts = [];
  List<PayeeOption> _recentPayees = [];

  final TextEditingController toIbanController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    toIbanController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final accounts =
          await WalletAccountService.instance.fetchAccounts(forceRefresh: true);
      final payees = await WalletAccountService.instance.recentPayees();
      if (!mounted) return;

      final preset = widget.receiverIban ?? extractIban(toIbanController.text);
      setState(() {
        _accounts = accounts;
        _recentPayees = payees;
        _loading = false;
        if (accounts.isNotEmpty && selectedFromIban == null) {
          selectedFromIban = accounts.first.iban;
        }
        if (preset != null && preset.isNotEmpty) {
          _useCustomIban = true;
          selectedToKey = _customPayee;
          toIbanController.text = preset;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<DropdownMenuItem<String>> _toDropdownItems() {
    final items = <DropdownMenuItem<String>>[];
    final from = selectedFromIban;

    for (final account in _accounts) {
      if (account.iban == from) continue;
      items.add(DropdownMenuItem(
        value: 'own:${account.iban}',
        child: Text('My ${account.label}'),
      ));
    }

    for (final payee in _recentPayees) {
      if (payee.iban == from) continue;
      items.add(DropdownMenuItem(
        value: 'recent:${payee.iban}',
        child: Text('Recent · ${payee.label}'),
      ));
    }

    items.add(const DropdownMenuItem(
      value: _customPayee,
      child: Text('Enter IBAN manually'),
    ));
    return items;
  }

  String? _resolveToIban() {
    if (_useCustomIban || selectedToKey == _customPayee) {
      return extractIban(toIbanController.text) ?? toIbanController.text.trim();
    }
    final key = selectedToKey;
    if (key == null) return null;
    final parts = key.split(':');
    if (parts.length == 2) return parts[1];
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send money')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 12),
                Text(
                  'Choose accounts — no need to remember full IBANs.',
                  style: greyTextStyle.copyWith(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 20),
                CustomDropDownFieldButton<String>(
                  title: 'Pay from',
                  value: selectedFromIban,
                  items: _accounts
                      .map((a) => DropdownMenuItem(
                            value: a.iban,
                            child: Text(a.label),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedFromIban = value),
                ),
                const SizedBox(height: 16),
                CustomDropDownFieldButton<String>(
                  title: 'Send to',
                  value: selectedToKey,
                  items: _toDropdownItems(),
                  onChanged: (value) {
                    setState(() {
                      selectedToKey = value;
                      _useCustomIban = value == _customPayee;
                      if (!_useCustomIban && value != null && value.contains(':')) {
                        toIbanController.text = value.split(':').last;
                      }
                    });
                  },
                ),
                if (_useCustomIban || selectedToKey == _customPayee) ...[
                  const SizedBox(height: 12),
                  CustomTextField(
                    title: 'Recipient IBAN',
                    hintText: 'Paste or type IBAN',
                    controller: toIbanController,
                  ),
                ],
                const SizedBox(height: 12),
                CustomTextField(
                  title: 'Note (optional)',
                  hintText: 'What is this for?',
                  controller: descriptionController,
                ),
                const SizedBox(height: 28),
                CustomFilledButton(
                  title: 'Enter amount',
                  onPressed: () {
                    if (selectedFromIban == null) {
                      _showError('Choose the account to pay from.');
                      return;
                    }
                    final toIban = _resolveToIban();
                    if (toIban == null || toIban.isEmpty) {
                      _showError('Choose or enter a recipient.');
                      return;
                    }
                    if (selectedFromIban == toIban) {
                      _showError('Source and destination must differ.');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransferAmountPage(
                          fromIban: selectedFromIban!,
                          toIban: toIban,
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
