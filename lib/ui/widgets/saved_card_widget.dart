import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';

/// Displays a saved (masked) card — avoids flutter_credit_card's full-PAN requirement.
class SavedCardWidget extends StatelessWidget {
  const SavedCardWidget({
    super.key,
    required this.cardHolderName,
    required this.maskedNumber,
    required this.expiryDate,
    this.brand,
    this.height = 200,
    this.width = 320,
  });

  final String cardHolderName;
  final String maskedNumber;
  final String expiryDate;
  final String? brand;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [purpleColor, purpleColor.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: purpleColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                brand ?? 'CARD',
                style: whiteTextStyle.copyWith(
                  fontSize: 13,
                  fontWeight: semiBold,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(Icons.contactless_outlined, color: whiteColor.withOpacity(0.9)),
            ],
          ),
          const Spacer(),
          Text(
            maskedNumber,
            style: whiteTextStyle.copyWith(
              fontSize: 18,
              fontWeight: medium,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARD HOLDER',
                      style: whiteTextStyle.copyWith(
                        fontSize: 10,
                        color: whiteColor.withOpacity(0.75),
                      ),
                    ),
                    Text(
                      cardHolderName.toUpperCase(),
                      style: whiteTextStyle.copyWith(fontSize: 13, fontWeight: medium),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPIRES',
                    style: whiteTextStyle.copyWith(
                      fontSize: 10,
                      color: whiteColor.withOpacity(0.75),
                    ),
                  ),
                  Text(
                    expiryDate,
                    style: whiteTextStyle.copyWith(fontSize: 13, fontWeight: medium),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
