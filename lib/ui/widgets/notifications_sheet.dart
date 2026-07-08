import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class NotificationsSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final items = [
      _NotificationItem(
        icon: Icons.account_balance_wallet_outlined,
        color: purpleColor,
        title: 'Wallet topped up',
        body: 'Your last Razorpay top-up was credited successfully.',
        time: '2h ago',
      ),
      _NotificationItem(
        icon: Icons.swap_horiz_rounded,
        color: blueColor,
        title: 'Transfer completed',
        body: 'A recent transfer between your accounts is complete.',
        time: 'Yesterday',
      ),
      _NotificationItem(
        icon: Icons.security_outlined,
        color: greenColor,
        title: 'Secure session',
        body: 'Your login session is protected with JWT refresh tokens.',
        time: 'Today',
      ),
    ];

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
          ...items.map((item) => _NotificationTile(item: item)),
        ],
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
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
                    Text(
                      item.time,
                      style: greyTextStyle.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: greyTextStyle.copyWith(fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
