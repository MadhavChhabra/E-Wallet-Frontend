import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/transaction_item.dart';
import 'package:flutter_ewallet/services/transaction_service.dart';
import 'package:flutter_ewallet/ui/widgets/app_section_card.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:intl/intl.dart';

import '../widgets/custom_latest_transaction_item.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<TransactionItem> latestTransactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions({bool forceRefresh = false}) async {
    try {
      final items = await TransactionService.instance.fetchForCurrentUser(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        latestTransactions = items;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _loadTransactions(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(
              'Transaction history',
              style: blackTextStyle.copyWith(
                fontSize: 24,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'All wallet activity grouped by month',
              style: greyTextStyle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const AppSectionCard(
                child: SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              )
            else if (latestTransactions.isEmpty)
              AppSectionCard(
                child: Text(
                  'No transactions yet. Try a transfer or top-up.',
                  style: greyTextStyle.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ..._buildMonthlySections(latestTransactions),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMonthlySections(List<TransactionItem> transactions) {
    final grouped = <String, List<TransactionItem>>{};

    for (final transaction in transactions) {
      final month = DateFormat('MMMM yyyy').format(transaction.createdAt);
      grouped.putIfAbsent(month, () => []).add(transaction);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aDate = DateFormat('MMMM yyyy').parse(a);
        final bDate = DateFormat('MMMM yyyy').parse(b);
        return bDate.compareTo(aDate);
      });

    return sortedKeys.map((month) {
      return _buildSection(month, grouped[month]!);
    }).toList();
  }

  Widget _buildSection(String title, List<TransactionItem> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 16),
          ),
        ),
        AppSectionCard(
          child: Column(
            children: transactions
                .map(
                  (transaction) => LatestTransactionItem(
                    iconUrl: transaction.iconUrl,
                    title: transaction.title,
                    time: transaction.timeLabel,
                    value: transaction.value,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
