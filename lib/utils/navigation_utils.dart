import 'package:flutter/material.dart';

/// Pops the route stack, or returns to home when there is nowhere to pop
/// (common on web where the browser back button would leave the site).
void popOrHome(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }
}

/// Intercepts system / browser back and routes in-app instead of closing the tab.
class WebSafePopScope extends StatelessWidget {
  const WebSafePopScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        popOrHome(context);
      },
      child: child,
    );
  }
}

/// Standard in-app back control for secondary screens.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: color),
      onPressed: () => popOrHome(context),
    );
  }
}
