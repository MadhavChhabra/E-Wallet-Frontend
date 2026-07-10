import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/transaction_item.dart';
import 'package:flutter_ewallet/services/transaction_service.dart';
import 'package:flutter_ewallet/ui/pages/transaction_detail_page.dart';
import 'package:flutter_ewallet/ui/widgets/app_section_card.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_latest_transaction_item.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final List<TransactionItem> _transactions = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    AppEvents.instance.walletChanged.addListener(_onWalletChanged);
    _loadTransactions(reset: true);
  }

  @override
  void dispose() {
    AppEvents.instance.walletChanged.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() => _loadTransactions(reset: true);

  Future<void> _loadTransactions({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 0;
        _hasMore = true;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    try {
      final result = await TransactionService.instance.fetchPage(
        page: reset ? 0 : _page,
        size: 20,
        forceRefresh: reset,
      );
      if (!mounted) return;
      setState(() {
        if (reset) _transactions.clear();
        _transactions.addAll(result.items);
        _page = result.page + 1;
        _hasMore = result.hasMore;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _openDetail(TransactionItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailPage(transactionId: item.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _loadTransactions(reset: true),
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
            else if (_error != null && _transactions.isEmpty)
              AppSectionCard(
                child: Column(
                  children: [
                    Text(
                      'Couldn\'t load transactions',
                      style: blackTextStyle.copyWith(fontWeight: semiBold),
                    ),
                    const SizedBox(height: 8),
                    Text(_error!, style: greyTextStyle.copyWith(fontSize: 13)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _loadTransactions(reset: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_transactions.isEmpty)
              AppSectionCard(
                child: Column(
                  children: [
                    Text(
                      'No transactions yet. Try a transfer or top-up.',
                      style: greyTextStyle.copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CustomFilledButton(
                      title: 'Send money',
                      onPressed: () =>
                          Navigator.pushNamed(context, '/transfer'),
                    ),
                    const SizedBox(height: 8),
                    CustomTextButton(
                      title: 'Top up wallet',
                      onPressed: () =>
                          Navigator.pushNamed(context, '/topup-amount'),
                    ),
                  ],
                ),
              )
            else ...[
              ..._buildMonthlySections(_transactions),
              if (_hasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: _loadingMore
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : OutlinedButton(
                            onPressed: () => _loadTransactions(),
                            child: const Text('Load more'),
                          ),
                  ),
                ),
            ],
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
                    onTap: () => _openDetail(transaction),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
