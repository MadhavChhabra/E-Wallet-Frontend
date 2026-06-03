import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/theme.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final bool obscureText;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    required this.title,
    this.obscureText = false,
    this.controller,
    this.hintText,
    this.keyboardType, this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: blackTextStyle.copyWith(
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
          obscureText: obscureText,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,hintStyle: greyTextStyle.copyWith(fontSize: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}
