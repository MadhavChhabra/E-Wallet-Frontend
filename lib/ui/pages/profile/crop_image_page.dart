import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/utils/theme.dart';

/// Interactive square/circular crop for the profile photo. Pure-Dart
/// (crop_your_image) so it works on web and mobile without native plugins.
/// Returns the cropped bytes via [Navigator.pop].
class CropImagePage extends StatefulWidget {
  const CropImagePage({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final CropController _controller = CropController();
  bool _cropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: darkBackgroundColor,
        foregroundColor: whiteColor,
        elevation: 0,
        title: const Text('Crop photo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.bytes,
              controller: _controller,
              aspectRatio: 1,
              withCircleUi: true,
              baseColor: darkBackgroundColor,
              maskColor: Colors.black.withOpacity(0.6),
              onCropped: (cropped) {
                if (!mounted) return;
                Navigator.of(context).pop(cropped);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Text(
                  'Pinch to zoom, drag to reposition',
                  style: greyTextStyle.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 12),
                _cropping
                    ? const Center(child: CircularProgressIndicator())
                    : CustomFilledButton(
                        title: 'Use photo',
                        onPressed: () {
                          setState(() => _cropping = true);
                          _controller.crop();
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
