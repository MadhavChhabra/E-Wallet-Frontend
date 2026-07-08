import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';

/// On desktop web, wraps the app in a centered phone-style frame for demo presentation.
class WebPhoneShell extends StatelessWidget {
  const WebPhoneShell({super.key, required this.child});

  final Widget child;

  static const double _phoneWidth = 390;
  static const double _phoneHeight = 844;
  static const double _wideBreakpoint = 520;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _wideBreakpoint) {
          return child;
        }

        const horizontalPadding = 48.0;
        const verticalPadding = 40.0;
        const bezel = 14.0;

        final maxFrameWidth = constraints.maxWidth - horizontalPadding;
        final maxFrameHeight = constraints.maxHeight - verticalPadding - 56;

        var scale = 1.0;
        if (maxFrameWidth < _phoneWidth + bezel * 2) {
          scale = maxFrameWidth / (_phoneWidth + bezel * 2);
        }
        if (maxFrameHeight < _phoneHeight + bezel * 2) {
          scale = scale < maxFrameHeight / (_phoneHeight + bezel * 2)
              ? scale
              : maxFrameHeight / (_phoneHeight + bezel * 2);
        }
        scale = scale.clamp(0.55, 1.0);

        final screenWidth = _phoneWidth * scale;
        final screenHeight = _phoneHeight * scale;
        final outerRadius = 44.0 * scale;
        final innerRadius = 32.0 * scale;
        final bezelSize = bezel * scale;

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
                purpleColor.withOpacity(0.08),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'E-Wallet Demo',
                  style: blackTextStyle.copyWith(
                    fontSize: 22,
                    fontWeight: semiBold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Test Mode · Mobile preview',
                  style: greyTextStyle.copyWith(fontSize: 13),
                ),
                SizedBox(height: 20 * scale),
                Container(
                  width: screenWidth + bezelSize * 2,
                  height: screenHeight + bezelSize * 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111118),
                    borderRadius: BorderRadius.circular(outerRadius),
                    border: Border.all(
                      color: const Color(0xFF2A2A33),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.18),
                        blurRadius: 48 * scale,
                        offset: Offset(0, 24 * scale),
                      ),
                      BoxShadow(
                        color: purpleColor.withOpacity(0.12),
                        blurRadius: 80 * scale,
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(bezelSize),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(innerRadius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            size: Size(screenWidth, screenHeight),
                            padding: EdgeInsets.only(top: 12 * scale),
                          ),
                          child: SizedBox(
                            width: screenWidth,
                            height: screenHeight,
                            child: child,
                          ),
                        ),
                        Positioned(
                          top: 8 * scale,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Center(
                              child: Container(
                                width: 96 * scale,
                                height: 24 * scale,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111118),
                                  borderRadius:
                                      BorderRadius.circular(16 * scale),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
