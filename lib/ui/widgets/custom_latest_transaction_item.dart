import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class LatestTransactionItem extends StatelessWidget {
  final String iconUrl;
  final String title;
  final String time;
  final String value;
  final VoidCallback? onTap;

  const LatestTransactionItem({
    super.key,
    required this.iconUrl,
    required this.title,
    required this.time,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = value.trimLeft().startsWith('+');
    final amountColor = isCredit ? greenColor : blackColor;

    final row = Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: lightBackgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(iconUrl, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: blackTextStyle.copyWith(
                    fontWeight: semiBold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: greyTextStyle.copyWith(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: blackTextStyle.copyWith(
              fontWeight: semiBold,
              fontSize: 15,
              color: amountColor,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: row,
    );
  }
}
