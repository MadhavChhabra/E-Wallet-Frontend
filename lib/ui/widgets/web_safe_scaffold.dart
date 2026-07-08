import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/navigation_utils.dart';
import 'package:flutter_ewallet/utils/theme.dart';

/// Scaffold with an in-app back button and safe browser-back handling for web.
class WebSafeScaffold extends StatelessWidget {
  const WebSafeScaffold({
    super.key,
    required this.body,
    this.title,
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.appBarForegroundColor,
    this.actions,
    this.centerTitle,
    this.floatingActionButton,
  });

  final Widget body;
  final String? title;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final Color? appBarForegroundColor;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final fg = appBarForegroundColor ?? blackColor;
    return WebSafePopScope(
      child: Scaffold(
        backgroundColor: backgroundColor ?? lightBackgroundColor,
        appBar: AppBar(
          backgroundColor: appBarBackgroundColor ?? lightBackgroundColor,
          foregroundColor: fg,
          iconTheme: IconThemeData(color: fg),
          leading: AppBackButton(color: fg),
          title: title != null ? Text(title!) : null,
          centerTitle: centerTitle,
          actions: actions,
        ),
        floatingActionButton: floatingActionButton,
        body: body,
      ),
    );
  }
}
