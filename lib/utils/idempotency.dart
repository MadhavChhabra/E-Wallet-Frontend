import 'dart:math';

/// Generates a unique idempotency key for money mutations.
String newIdempotencyKey() {
  final r = Random().nextInt(999999).toString().padLeft(6, '0');
  return '${DateTime.now().microsecondsSinceEpoch}-$r';
}
