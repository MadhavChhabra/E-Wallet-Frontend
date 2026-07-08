import 'razorpay_checkout.dart';
import 'razorpay_models.dart';

/// Fallback used on platforms without a Checkout implementation.
class _StubCheckout implements RazorpayCheckout {
  @override
  void open(
    RazorpayOptions options, {
    required RazorpaySuccess onSuccess,
    required RazorpayError onError,
  }) {
    onError('Payments are not supported on this platform');
  }

  @override
  void dispose() {}
}

RazorpayCheckout createRazorpayCheckout() => _StubCheckout();
