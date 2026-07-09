import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/widgets/animated_entrance.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class CustomInputPinButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomInputPinButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: numberBackgroundColor,
        ),
        child: Center(
          child: Text(
            text,
            style: whiteTextStyle.copyWith(
              fontSize: 22,
              fontWeight: semiBold,
            ),
          ),
        ),
      ),
    );
  }
}
