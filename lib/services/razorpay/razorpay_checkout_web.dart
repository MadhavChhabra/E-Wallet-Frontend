// This file is only ever compiled for Flutter web (selected via conditional
// import), where dart:js is the correct way to drive Razorpay's checkout.js.
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'razorpay_checkout.dart';

/// Web Checkout via Razorpay's checkout.js (loaded in web/index.html).
class _WebCheckout implements RazorpayCheckout {
  @override
  void open(
    RazorpayOptions options, {
    required RazorpaySuccess onSuccess,
    required RazorpayError onError,
  }) {
    final rzpConstructor = js.context['Razorpay'];
    if (rzpConstructor == null) {
      onError('Razorpay Checkout is not available');
      return;
    }

    final optionsJs = js.JsObject.jsify({
      'key': options.keyId,
      'order_id': options.orderId,
      'amount': options.amountInPaise,
      'currency': options.currency,
      'name': options.name,
      'description': options.description,
      'handler': js.allowInterop((resp) {
        final r = resp as js.JsObject;
        onSuccess(RazorpayResult(
          orderId: (r['razorpay_order_id'] ?? '').toString(),
          paymentId: (r['razorpay_payment_id'] ?? '').toString(),
          signature: (r['razorpay_signature'] ?? '').toString(),
        ));
      }),
      'modal': {
        'ondismiss': js.allowInterop(() => onError('Payment cancelled')),
      },
    });

    final rzp = js.JsObject(rzpConstructor as js.JsFunction, [optionsJs]);
    rzp.callMethod('open');
  }

  @override
  void dispose() {}
}

RazorpayCheckout createRazorpayCheckout() => _WebCheckout();
