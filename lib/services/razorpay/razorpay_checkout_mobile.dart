import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'razorpay_checkout.dart';

/// Native Android/iOS Checkout via the razorpay_flutter SDK.
class _MobileCheckout implements RazorpayCheckout {
  final Razorpay _razorpay = Razorpay();
  RazorpaySuccess? _onSuccess;
  RazorpayError? _onError;

  _MobileCheckout() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternal);
  }

  @override
  void open(
    RazorpayOptions options, {
    required RazorpaySuccess onSuccess,
    required RazorpayError onError,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _razorpay.open({
      'key': options.keyId,
      'order_id': options.orderId,
      'amount': options.amountInPaise,
      'currency': options.currency,
      'name': options.name,
      'description': options.description,
      'timeout': 300,
    });
  }

  void _handleSuccess(PaymentSuccessResponse r) {
    _onSuccess?.call(RazorpayResult(
      orderId: r.orderId ?? '',
      paymentId: r.paymentId ?? '',
      signature: r.signature ?? '',
    ));
  }

  void _handleError(PaymentFailureResponse r) {
    _onError?.call('Payment failed or cancelled');
  }

  void _handleExternal(ExternalWalletResponse r) {}

  @override
  void dispose() {
    _razorpay.clear();
  }
}

RazorpayCheckout createRazorpayCheckout() => _MobileCheckout();
