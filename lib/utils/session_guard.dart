import 'package:flutter/material.dart';

/// Redirects to sign-in when refresh-token renewal fails mid-session.
class SessionGuard {
  SessionGuard._();

  static GlobalKey<NavigatorState>? navigatorKey;

  static void redirectToSignIn({String? message}) {
    final nav = navigatorKey?.currentState;
    if (nav == null) return;
    nav.pushNamedAndRemoveUntil('/sign-in', (_) => false);
    if (message != null && message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = navigatorKey?.currentContext;
        if (ctx != null && ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      });
    }
  }
}
