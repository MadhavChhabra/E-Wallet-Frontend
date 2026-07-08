import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class WalletCard extends StatelessWidget {
  final int? index;
  final String name;
  final double balance;
  final String userFullName;
  final String iban;
  final List<String> backgroundImagePaths;

  const WalletCard({
    super.key,
    required this.name,
    required this.balance,
    required this.userFullName,
    required this.iban,
    this.backgroundImagePaths = const [
      'assets/bankCardBackgrounds/bg1.jpg',
      'assets/bankCardBackgrounds/bg2.jpg',
      'assets/bankCardBackgrounds/bg3.jpg',
      'assets/bankCardBackgrounds/bg4.jpg',
      'assets/bankCardBackgrounds/bg5.jpg',
      'assets/bankCardBackgrounds/bg6.jpg',
    ],
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cardIndex = index ?? 0;
    final backgroundImage = AssetImage(
      backgroundImagePaths[cardIndex % backgroundImagePaths.length],
    );

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 4, right: 4),
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: backgroundImage,
        ),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: whiteTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Available balance',
                    style: whiteTextStyle.copyWith(
                      fontSize: 12,
                      color: whiteColor.withOpacity(0.82),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${balance.toStringAsFixed(2)}',
                    style: whiteTextStyle.copyWith(
                      fontSize: 28,
                      fontWeight: bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'IBAN · ${iban.length > 18 ? '${iban.substring(0, 18)}…' : iban}',
                    style: whiteTextStyle.copyWith(
                      fontSize: 12,
                      color: whiteColor.withOpacity(0.88),
                    ),
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
