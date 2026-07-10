import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/services/wallet_account_service.dart';

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

  /// Returns the current user's preferred wallet IBAN, or null if they have none.
  static Future<String?> primaryWalletIban() async {
    return WalletAccountService.instance.preferredWalletIban();
  }
}
