import 'package:flutter/material.dart';

import '../../utils/theme.dart';

class CustomUser extends StatelessWidget {
  final Image image;
  final String userName;

  const CustomUser({
    super.key,
    required this.image,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: purpleColor.withOpacity(0.15), width: 2),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: image.image,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userName,
          style: blackTextStyle.copyWith(fontWeight: medium, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
