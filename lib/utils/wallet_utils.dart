/// Helpers for parsing wallet API payloads consistently.
class WalletUtils {
  static double parseBalance(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
