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
    Key? key,
    required this.iconUrl,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.preferredHeight = 26,
    this.preferredWidth = 26
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Image.asset(
                fit: BoxFit.fill,
                iconUrl,
                width: preferredWidth,
                height: preferredHeight,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            style: blackTextStyle.copyWith(
              fontWeight: medium,
            ),
          ),
          Text(
            subtitle,
            style: blackTextStyle.copyWith(
              fontWeight: medium,
            ),
          )
        ],
      ),
    );
  }
}
