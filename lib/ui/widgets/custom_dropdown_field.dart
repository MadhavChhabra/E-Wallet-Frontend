import 'package:flutter/material.dart';

class CustomDropDownFieldButton<T> extends StatefulWidget {
  final String title;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;

  const CustomDropDownFieldButton({
    Key? key,
    required this.title,
    required this.items,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomDropDownFieldButtonState<T> createState() =>
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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
