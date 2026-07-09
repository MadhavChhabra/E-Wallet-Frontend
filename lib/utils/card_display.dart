/// Maps `/cards` API responses to display fields for credit-card widgets.
///
/// Saved cards are returned masked — full PAN and CVV are never stored server-side.
class CardDisplay {
  static String number(Map<String, dynamic> card) {
    final masked = card['maskedNumber']?.toString();
    if (masked != null && masked.isNotEmpty) return masked;
    final last4 = card['last4']?.toString() ?? '****';
    return '**** **** **** $last4';
  }

  /// Placeholder only — CVV is not persisted or returned by the API.
  static String cvv(Map<String, dynamic> card) => '***';

  static String holder(Map<String, dynamic> card) =>
      card['cardHolderName']?.toString() ?? '';

  static String expiry(Map<String, dynamic> card) =>
      card['expiryDate']?.toString() ?? '';
}
