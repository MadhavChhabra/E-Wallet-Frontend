/// Extracts an IBAN from raw QR / pasted text (plain, prefixed, or JSON).
String? extractIban(String raw) {
  if (raw.trim().isEmpty) return null;

  final upper = raw.toUpperCase().replaceAll(RegExp(r'\s+'), '');

  // JSON payload: {"iban":"DE89..."}
  final jsonMatch = RegExp(r'"IBAN"\s*:\s*"([A-Z0-9]+)"', caseSensitive: false)
      .firstMatch(raw);
  if (jsonMatch != null) {
    return _validateIban(jsonMatch.group(1)!);
  }

  // Labelled: IBAN:DE89... or iban=DE89...
  final labelled = RegExp(r'IBAN[=:\s]+([A-Z]{2}\d{2}[A-Z0-9]{11,30})',
          caseSensitive: false)
      .firstMatch(upper);
  if (labelled != null) {
    return _validateIban(labelled.group(1)!);
  }

  final match =
      RegExp(r'[A-Z]{2}\d{2}[A-Z0-9]{11,30}').firstMatch(upper);
  return _validateIban(match?.group(0));
}

String? _validateIban(String? candidate) {
  if (candidate == null || candidate.length < 15) return null;
  return candidate;
}
