import 'razorpay_models.dart';
import 'razorpay_checkout_stub.dart'
    if (dart.library.io) 'razorpay_checkout_mobile.dart'
    if (dart.library.js) 'razorpay_checkout_web.dart';

export 'razorpay_models.dart';

/// Cross-platform Razorpay Checkout.
///
/// * Mobile (dart:io) → native `razorpay_flutter` SDK.
/// * Web (dart:js) → Razorpay Checkout JS (`checkout.js`, loaded in index.html).
///
/// The showcase top-up flow therefore works in the browser demo *and* the APK.
abstract class RazorpayCheckout {
  void open(
    RazorpayOptions options, {
    required RazorpaySuccess onSuccess,
    required RazorpayError onError,
  });

  void dispose();

  /// Returns the platform-appropriate implementation.
  factory RazorpayCheckout() => createRazorpayCheckout();
}
