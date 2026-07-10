import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/transaction_item.dart';
import 'package:flutter_ewallet/services/transaction_service.dart';
import 'package:flutter_ewallet/ui/pages/transaction_detail_page.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:intl/intl.dart';

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsSheet(),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  List<TransactionItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items =
          await TransactionService.instance.fetchForCurrentUser(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _items = items.take(6).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _relativeTime(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(when);
  }

  IconData _iconFor(TransactionItem item) {
    if (item.title.toLowerCase().contains('top')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (item.isOutgoing) return Icons.north_east_rounded;
    return Icons.south_west_rounded;
  }

  Color _colorFor(TransactionItem item) {
    if (item.title.toLowerCase().contains('top')) return purpleColor;
    return item.isOutgoing ? blueColor : greenColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Notifications',
            style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
          ),
          const SizedBox(height: 4),
          Text(
            'Recent wallet activity',
            style: greyTextStyle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No recent activity yet.',
                style: greyTextStyle.copyWith(fontSize: 14),
              ),
            )
          else
            ..._items.map((item) => _NotificationTile(
                  item: item,
                  icon: _iconFor(item),
                  color: _colorFor(item),
                  time: _relativeTime(item.createdAt),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionDetailPage(transactionId: item.id),
                      ),
                    );
                  },
                )),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.icon,
    required this.color,
    required this.time,
    required this.onTap,
  });

  final TransactionItem item;
  final IconData icon;
  final Color color;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: lightBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: blackTextStyle.copyWith(
                            fontWeight: semiBold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(time, style: greyTextStyle.copyWith(fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.value}${item.counterpartyUsername != null ? ' · ${item.counterpartyUsername}' : ''}',
                    style: greyTextStyle.copyWith(fontSize: 13, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
