import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';

/// Colour scheme for a saved card. Known networks get a signature look; anything
/// else rotates through a set of gradients so a wallet of cards never renders as
/// a stack of identical rectangles.
class CardPalette {
  const CardPalette(this.gradient, this.glow);

  final List<Color> gradient;
  final Color glow;

  static CardPalette forCard(String? brand, int index) {
    switch ((brand ?? '').toLowerCase().replaceAll(' ', '')) {
      case 'visa':
        return const CardPalette(
            [Color(0xff1A1F71), Color(0xff2D53D6)], Color(0xff1A1F71));
      case 'master':
      case 'mastercard':
        return const CardPalette(
            [Color(0xff232526), Color(0xff414345)], Color(0xff000000));
      case 'amex':
      case 'americanexpress':
        return const CardPalette(
            [Color(0xff0F7B6C), Color(0xff16A085)], Color(0xff0F7B6C));
      case 'discover':
      case 'verve':
        return const CardPalette(
            [Color(0xffE86A17), Color(0xffF29D38)], Color(0xffE86A17));
      default:
        return _rotation[index % _rotation.length];
    }
  }

  static const List<CardPalette> _rotation = [
    CardPalette([Color(0xff5142E6), Color(0xff7C6BFF)], Color(0xff5142E6)),
    CardPalette([Color(0xffEC407A), Color(0xff8E24AA)], Color(0xff8E24AA)),
    CardPalette([Color(0xff0F2027), Color(0xff2C5364)], Color(0xff0F2027)),
    CardPalette([Color(0xff11998E), Color(0xff38EF7D)], Color(0xff11998E)),
    CardPalette([Color(0xffF7971E), Color(0xffE8A020)], Color(0xffF7971E)),
  ];
}

/// A small gold EMV-style chip drawn with gradients (no asset needed).
class _CardChip extends StatelessWidget {
  const _CardChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [Color(0xffD4AF37), Color(0xffF9E29C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 26,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0x55000000), width: 1),
          ),
        ),
      ),
    );
  }
}

/// Front face of a saved (masked) card. Avoids flutter_credit_card's full-PAN
/// requirement — full PAN/CVV are never stored server-side.
class SavedCardWidget extends StatelessWidget {
  const SavedCardWidget({
    super.key,
    required this.cardHolderName,
    required this.maskedNumber,
    required this.expiryDate,
    this.brand,
    this.palette,
    this.height = 210,
    this.width = 340,
  });

  final String cardHolderName;
  final String maskedNumber;
  final String expiryDate;
  final String? brand;
  final CardPalette? palette;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? CardPalette.forCard(brand, 0);
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: p.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: p.glow.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
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
                (brand == null || brand!.isEmpty ? 'CARD' : brand!)
                    .toUpperCase(),
                style: whiteTextStyle.copyWith(
                  fontSize: 13,
                  fontWeight: semiBold,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(Icons.contactless_outlined,
                  color: whiteColor.withOpacity(0.9)),
            ],
          ),
          const SizedBox(height: 16),
          const _CardChip(),
          const Spacer(),
          Text(
            maskedNumber,
            style: whiteTextStyle.copyWith(
              fontSize: 18,
              fontWeight: medium,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 16),
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
                      style: whiteTextStyle.copyWith(
                          fontSize: 13, fontWeight: medium),
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
                    style: whiteTextStyle.copyWith(
                        fontSize: 13, fontWeight: medium),
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

/// Back face of a saved card — magnetic stripe + signature panel, shown after the
/// flip so the selected card reads like a physical card turning over.
class SavedCardBack extends StatelessWidget {
  const SavedCardBack({
    super.key,
    required this.cardHolderName,
    required this.maskedNumber,
    required this.expiryDate,
    this.brand,
    this.palette,
    this.height = 210,
    this.width = 340,
  });

  final String cardHolderName;
  final String maskedNumber;
  final String expiryDate;
  final String? brand;
  final CardPalette? palette;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? CardPalette.forCard(brand, 0);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: p.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: p.glow.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Magnetic stripe.
          Container(height: 42, color: const Color(0xff101010)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Signature panel with masked number.
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: whiteColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'CVV  ***',
                    style: blackTextStyle.copyWith(
                        fontSize: 12, fontWeight: semiBold, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  maskedNumber,
                  style: whiteTextStyle.copyWith(
                      fontSize: 15, letterSpacing: 1.2),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        cardHolderName.toUpperCase(),
                        style: whiteTextStyle.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      expiryDate,
                      style: whiteTextStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 22, bottom: 14),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tap to flip back',
                style: whiteTextStyle.copyWith(
                    fontSize: 10, color: whiteColor.withOpacity(0.7)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Flips between [front] and [back] around the vertical axis when [showBack]
/// toggles. Self-contained (no controller) so it composes cleanly inside the
/// animated card stack.
class FlipCard extends StatelessWidget {
  const FlipCard({
    super.key,
    required this.showBack,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 420),
  });

  final bool showBack;
  final Widget front;
  final Widget back;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: showBack ? 1.0 : 0.0),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, t, _) {
        final angle = t * math.pi;
        final isBack = t > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}
