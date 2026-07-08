import 'package:flutter/material.dart';

import '../../utils/theme.dart';

class CustomHomeServices extends StatelessWidget {
  final String iconUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final double preferredWidth;
  final double preferredHeight;

  const CustomHomeServices({
    super.key,
    required this.iconUrl,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.preferredHeight = 26,
    this.preferredWidth = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: 78,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    iconUrl,
                    width: preferredWidth,
                    height: preferredHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: blackTextStyle.copyWith(
                  fontWeight: medium,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: greyTextStyle.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
