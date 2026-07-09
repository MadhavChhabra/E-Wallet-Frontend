import 'package:flutter/material.dart';

/// Prompts for the local security PIN before a payment / transfer executes.
Future<bool> requirePin(BuildContext context) async {
  final result = await Navigator.pushNamed(context, '/pin');
  return result == true;
}
