import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/widgets/animated_entrance.dart';
import 'package:flutter_ewallet/utils/theme.dart';

/// A stable, responsive 3-column numeric keypad (digits 0-9 + delete).
///
/// Key size is derived from the available width via [LayoutBuilder], so the
/// grid scales down cleanly inside the web phone-shell (or on small devices)
/// and **never reflows** into a different column count — fixing the button
/// rearrangement seen on the PIN / amount screens.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.keyColor,
    this.textColor,
    this.maxWidth = 300,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final Color? keyColor;
  final Color? textColor;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final bg = keyColor ?? numberBackgroundColor;
    final fg = textColor ?? whiteColor;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const columns = 3;
            const gap = 18.0;
            final available = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : maxWidth;
            final keySize =
                ((available - gap * (columns - 1)) / columns).clamp(46.0, 72.0);

            Widget digit(String value) => _KeypadKey(
                  size: keySize,
                  color: bg,
                  onTap: () => onDigit(value),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: fg,
                      fontSize: keySize * 0.36,
                      fontWeight: semiBold,
                    ),
                  ),
                );

            Widget row(List<Widget> children) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      children[i],
                    ],
                  ],
                );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                row([digit('1'), digit('2'), digit('3')]),
                const SizedBox(height: gap),
                row([digit('4'), digit('5'), digit('6')]),
                const SizedBox(height: gap),
                row([digit('7'), digit('8'), digit('9')]),
                const SizedBox(height: gap),
                row([
                  SizedBox(width: keySize, height: keySize),
                  digit('0'),
                  _KeypadKey(
                    size: keySize,
                    color: bg,
                    onTap: onDelete,
                    child: Icon(Icons.backspace_outlined,
                        color: fg, size: keySize * 0.34),
                  ),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.size,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final double size;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Center(child: child),
      ),
    );
  }
}
