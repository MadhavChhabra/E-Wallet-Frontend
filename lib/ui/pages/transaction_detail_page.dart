import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/transaction_item.dart';
import 'package:flutter_ewallet/services/transaction_service.dart';
import 'package:flutter_ewallet/ui/widgets/app_section_card.dart';
import 'package:flutter_ewallet/utils/shared.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  TransactionItem? _item;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final item =
          await TransactionService.instance.fetchById(widget.transactionId);
      if (!mounted) return;
      setState(() {
        _item = item;
        _loading = false;
        _error = item == null ? 'Transaction not found' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              _error = null;
                            });
                            _load();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    AppSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _item!.title,
                            style: blackTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: semiBold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _item!.value,
                            style: blackTextStyle.copyWith(
                              fontSize: 28,
                              fontWeight: semiBold,
                              color: _item!.isOutgoing ? blackColor : greenColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _DetailRow('Date', _item!.timeLabel),
                          if (_item!.counterpartyUsername != null)
                            _DetailRow('Contact', _item!.counterpartyUsername!),
                          if (_item!.counterpartyIban != null)
                            _DetailRow('IBAN', _item!.counterpartyIban!),
                          if (_item!.description?.isNotEmpty == true)
                            _DetailRow('Note', _item!.description!),
                          if (_item!.referenceNumber != null)
                            _DetailRow('Reference', _item!.referenceNumber!),
                          _DetailRow(
                            'Amount',
                            formatCurrency(_item!.amount),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: greyTextStyle.copyWith(fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: blackTextStyle.copyWith(fontSize: 14, fontWeight: medium),
            ),
          ),
        ],
      ),
    );
  }
}
