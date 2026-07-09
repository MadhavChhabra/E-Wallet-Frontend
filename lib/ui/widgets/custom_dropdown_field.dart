import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class CustomDropDownFieldButton<T> extends StatefulWidget {
  final String title;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;

  const CustomDropDownFieldButton({
    super.key,
    required this.title,
    required this.items,
    this.value,
    this.onChanged,
  });

  @override
  State<CustomDropDownFieldButton<T>> createState() =>
      _CustomDropDownFieldButtonState<T>();
}

class _CustomDropDownFieldButtonState<T>
    extends State<CustomDropDownFieldButton<T>> {
  late T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: blackTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
        ),
        const SizedBox(
          height: 8,
        ),
        DropdownButtonFormField<T>(
          value: _selectedValue,
          items: widget.items,
              
          onChanged: (value) {
            setState(() {
              _selectedValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          decoration: InputDecoration(
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
