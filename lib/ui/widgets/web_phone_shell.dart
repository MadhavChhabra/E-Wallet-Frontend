import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';

/// On desktop web, wraps the app in a centered phone-style frame for demo presentation.
class WebPhoneShell extends StatelessWidget {
  const WebPhoneShell({super.key, required this.child});

  final Widget child;

  /// Mobile aspect ratio (width : height). Slightly wider than a tall phone so
  /// content doesn't feel cramped inside the desktop preview frame.
  static const double _aspectRatio = 9 / 18.2;
  static const double _minWidth = 390;
  static const double _maxWidth = 468;
  static const double _wideBreakpoint = 520;

  static _PhoneDimensions _dimensions(BoxConstraints constraints) {
    if (constraints.maxWidth <= _wideBreakpoint) {
      return _PhoneDimensions(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        scale: 1,
        showFrame: false,
      );
    }

    final isLargeDesktop = constraints.maxWidth >= 1200;
    final headerBlock = isLargeDesktop ? 0.0 : 72.0;
    final horizontalPad = isLargeDesktop ? 64.0 : 32.0;
    const verticalPad = 28.0;

    final maxW = constraints.maxWidth - horizontalPad * 2;
    final maxH = constraints.maxHeight - verticalPad * 2 - headerBlock;

    // Height-first sizing keeps the app readable on laptops; width follows aspect ratio.
    var height = maxH * (isLargeDesktop ? 0.94 : 0.90);
    var width = height * _aspectRatio;

    if (width > maxW) {
      width = maxW;
      height = width / _aspectRatio;
    }

    width = width.clamp(_minWidth, _maxWidth);
    height = width / _aspectRatio;

    if (height > maxH) {
      height = maxH;
      width = height * _aspectRatio;
    }

    final scale = width / _maxWidth;

    return _PhoneDimensions(
      width: width,
      height: height,
      scale: scale.clamp(0.72, 1.0),
      showFrame: true,
      isLargeDesktop: isLargeDesktop,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dims = _dimensions(constraints);
        if (!dims.showFrame) return child;

        final bezel = 12.0 * dims.scale;
        final outerRadius = 40.0 * dims.scale;
        final innerRadius = 28.0 * dims.scale;

        final phone = _PhoneFrame(
          dims: dims,
          bezel: bezel,
          outerRadius: outerRadius,
          innerRadius: innerRadius,
          child: child,
        );

        if (dims.isLargeDesktop) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF6F8FB),
                  Color(0xFFE9EDF5),
                  Color(0xFFF3F0FF),
                ],
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    child: _DesktopSidePanel(scale: dims.scale),
                  ),
                  SizedBox(width: 48 * dims.scale),
                  phone,
                ],
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                lightBackgroundColor,
                const Color(0xFFE8ECF4),
                purpleColor.withOpacity(0.07),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'E-Wallet Demo',
                style: blackTextStyle.copyWith(
                  fontSize: 20 + 2 * dims.scale,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Test Mode · Mobile preview',
                style: greyTextStyle.copyWith(fontSize: 12 + dims.scale),
              ),
              SizedBox(height: 18 * dims.scale),
              phone,
            ],
          ),
        );
      },
    );
  }
}

class _PhoneDimensions {
  const _PhoneDimensions({
    required this.width,
    required this.height,
    required this.scale,
    required this.showFrame,
    this.isLargeDesktop = false,
  });

  final double width;
  final double height;
  final double scale;
  final bool showFrame;
  final bool isLargeDesktop;
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({
    required this.dims,
    required this.bezel,
    required this.outerRadius,
    required this.innerRadius,
    required this.child,
  });

  final _PhoneDimensions dims;
  final double bezel;
  final double outerRadius;
  final double innerRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dims.width + bezel * 2,
      height: dims.height + bezel * 2,
      decoration: BoxDecoration(
        color: const Color(0xFF101015),
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(color: const Color(0xFF2E2E38), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.2),
            blurRadius: 40 * dims.scale,
            offset: Offset(0, 20 * dims.scale),
          ),
        ],
      ),
      padding: EdgeInsets.all(bezel),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: Size(dims.width, dims.height),
                padding: EdgeInsets.only(top: 10 * dims.scale),
                textScaler: const TextScaler.linear(1.0),
              ),
              child: SizedBox(
                width: dims.width,
                height: dims.height,
                child: child,
              ),
            ),
            Positioned(
              top: 6 * dims.scale,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: 88 * dims.scale,
                    height: 22 * dims.scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101015),
                      borderRadius: BorderRadius.circular(14 * dims.scale),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopSidePanel extends StatelessWidget {
  const _DesktopSidePanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: purpleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'LIVE DEMO',
            style: TextStyle(
              color: purpleColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'E-Wallet',
          style: blackTextStyle.copyWith(
            fontSize: 34,
            fontWeight: bold,
            height: 1.1,
          ),
        ),
        Text(
          'Digital Wallet',
          style: greyTextStyle.copyWith(fontSize: 16),
        ),
        SizedBox(height: 20 * scale),
        Text(
          'Experience transfers, top-ups, cards, and transaction history in a mobile-first wallet built with Flutter + Spring Boot.',
          style: greyTextStyle.copyWith(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24 * scale),
        const _SideFeature(icon: Icons.bolt_outlined, label: 'One-click demo account'),
        const _SideFeature(icon: Icons.security_outlined, label: 'JWT-secured API'),
        const _SideFeature(icon: Icons.payments_outlined, label: 'Razorpay test checkout'),
      ],
    );
  }
}

class _SideFeature extends StatelessWidget {
  const _SideFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: purpleColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: blackTextStyle.copyWith(fontSize: 13, fontWeight: medium),
            ),
          ),
        ],
      ),
    );
  }
}
