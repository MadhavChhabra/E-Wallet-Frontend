/// Result returned by the Razorpay Checkout on success.
class RazorpayResult {
  final String orderId;
  final String paymentId;
  final String signature;

  RazorpayResult({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });
}

/// Parameters needed to open the Checkout.
class RazorpayOptions {
  final String keyId;
  final String orderId;
  final int amountInPaise;
  final String currency;
  final String name;
  final String description;

  RazorpayOptions({
    required this.keyId,
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
    this.name = 'E-Wallet',
    this.description = 'Wallet Top-up',
  });
}

typedef RazorpaySuccess = void Function(RazorpayResult result);
typedef RazorpayError = void Function(String message);
