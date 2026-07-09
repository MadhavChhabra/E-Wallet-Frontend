import 'dart:math';

/// Generates IBANs that pass the backend's `IbanValidator` (standard ISO 13616
/// mod-97 check). Format matches the server's `IbanGenerator`: country `DE` +
/// 2 check digits + a 16-digit BBAN.
///
/// The check is computed exactly as the server does: move the first 4 chars to
/// the end, map letters A-Z to 10-35, and require the mod-97 remainder to be 1.
String generateIban() {
  final rnd = Random.secure();
  final bban = List.generate(16, (_) => rnd.nextInt(10)).join();
  for (var check = 2; check <= 98; check++) {
    final cc = check.toString().padLeft(2, '0');
    // Rearranged string = BBAN + country code + check digits.
    if (_mod97('${bban}DE$cc') == 1) {
      return 'DE$cc$bban';
    }
  }
  // Exactly one check value is valid for a given BBAN; unreachable.
  throw StateError('Could not derive valid IBAN check digits');
}

int _mod97(String rearranged) {
  var total = 0;
  for (var i = 0; i < rearranged.length; i++) {
    // radix-36 parse: '0'-'9' -> 0-9, 'A'-'Z' -> 10-35 (matches the server).
    final value = int.parse(rearranged[i], radix: 36);
    total = (value > 9 ? total * 100 : total * 10) + value;
    total %= 97;
  }
  return total;
}
