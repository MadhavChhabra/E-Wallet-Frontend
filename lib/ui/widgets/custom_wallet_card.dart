import 'dart:math';

import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class WalletCard extends StatefulWidget {
  final int? index;
  final String name;
  final double balance;
  final String userFullName;
  final String iban;
  final List<String> backgroundImagePaths; // List of background image paths
  final int upperLimit; // Upper limit for image names (optional)

  const WalletCard({
    Key? key,
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
      'assets/bankCardBackgrounds/bg6.jpg'
    ], // Default path
    this.upperLimit = 6, this.index, // Default upper limit (optional)
  }) : super(key: key);

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final int cardIndex =
        widget.index ?? 1;
    final backgroundImage = AssetImage(widget
        .backgroundImagePaths[cardIndex % widget.backgroundImagePaths.length]);

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 30.0, left: 5.0, right: 5.0),
        padding: const EdgeInsets.all(30.0),
        width: double.infinity,
        height: 220.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.0),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: backgroundImage,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name.toUpperCase(),
              style:
                  whiteTextStyle.copyWith(fontSize: 18.0, fontWeight: medium),
            ),
            const SizedBox(height: 28.0),
            Text(
              'Balance: ₹ ${widget.balance.toStringAsFixed(2)}',
              style:
                  whiteTextStyle.copyWith(fontSize: 18.0, fontWeight: medium),
            ),
            const SizedBox(height: 20.0),
            Text('IBAN: ${widget.iban}', style: whiteTextStyle),
          ],
        ),
      ),
    );
  }
}
