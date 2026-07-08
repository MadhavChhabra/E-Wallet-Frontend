import 'package:flutter_ewallet/services/http_service.dart';

/// Client for the backend's Razorpay top-up endpoints.
class PaymentService {
  /// Creates a Razorpay order for a wallet top-up. Returns the order details
  /// (orderId, keyId, amountInPaise, currency) needed to open Checkout.
  static Future<Map<String, dynamic>> createOrder({
    required double amount,
    required String toBankAccountIban,
  }) async {
    final res = await HttpService.postWithAuth('/payments/razorpay/order', {
      'amount': amount,
      'toBankAccountIban': toBankAccountIban,
    });
    final data = res['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception(res['message'] ?? 'Failed to create payment order');
  }

  /// Submits the signed Checkout result for server-side verification. On success
  /// the wallet has been credited.
  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final res = await HttpService.postWithAuth('/payments/razorpay/verify', {
      'razorpayOrderId': orderId,
      'razorpayPaymentId': paymentId,
      'razorpaySignature': signature,
    });
    final data = res['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception(res['message'] ?? 'Payment verification failed');
  }

  /// Returns the current user's first wallet IBAN, or null if they have none.
  static Future<String?> primaryWalletIban() async {
    final res = await HttpService.getWithAuth('/bank-accounts');
    final data = res['data'];
    List<dynamic>? content;
    if (data is Map && data['content'] is List) {
      content = data['content'] as List<dynamic>;
    } else if (data is List) {
      content = data;
    }
    if (content != null && content.isNotEmpty) {
      return content.first['iban'] as String?;
    }
    return null;
  }
}
