import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';

/// Circular avatar with the photo clipped inside the ring border.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.image,
    this.size = 48,
    this.onTap,
    this.showBadge = false,
  });

  final ImageProvider image;
  final double size;
  final VoidCallback? onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final innerSize = size - 6;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: purpleColor.withOpacity(0.35),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: purpleColor.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: innerSize,
                      height: innerSize,
                      child: Image(
                        image: image,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),
              if (showBadge)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: size * 0.28,
                    height: size * 0.28,
                    decoration: BoxDecoration(
                      color: greenColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: whiteColor, width: 2),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: whiteColor,
                      size: size * 0.16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
