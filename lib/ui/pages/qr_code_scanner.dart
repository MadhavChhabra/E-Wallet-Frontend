import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_page.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/utils/iban_utils.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scan-to-pay: reads a payment QR (containing an IBAN) using the device or
/// browser camera via mobile_scanner, with manual IBAN entry as a fallback when
/// the camera is unavailable or the user prefers to type.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _manualIbanController = TextEditingController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    _manualIbanController.dispose();
    super.dispose();
  }

  void _openTransfer(String raw) {
    final iban = extractIban(raw);
    if (iban == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid IBAN found in that code')),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TransferPage(receiverIban: iban),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue?.trim();
      if (code == null || code.isEmpty) continue;
      if (extractIban(code) == null) continue;
      _handled = true;
      _controller.stop();
      if (!mounted) return;
      _openTransfer(code);
      return;
    }
  }

  void _onManualContinue() => _openTransfer(_manualIbanController.text);

  @override
  Widget build(BuildContext context) {
    final cutOut = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) =>
                _CameraUnavailable(controller: _manualIbanController,
                    onContinue: _onManualContinue),
          ),
          // Scan frame
          IgnorePointer(
            child: Center(
              child: Container(
                width: cutOut,
                height: cutOut,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          // Top bar: close + torch
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: whiteColor,
                    iconSize: 28,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ValueListenableBuilder<TorchState>(
                    valueListenable: _controller.torchState,
                    builder: (context, state, _) => IconButton(
                      icon: Icon(state == TorchState.on
                          ? Icons.flash_on
                          : Icons.flash_off),
                      color: whiteColor,
                      iconSize: 28,
                      onPressed: () => _controller.toggleTorch(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom: manual entry
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Point at a payment QR code',
                    style:
                        blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
                  ),
                  const SizedBox(height: 8),
                  Text('Or enter the IBAN manually',
                      style: greyTextStyle.copyWith(fontSize: 13)),
                  const SizedBox(height: 12),
                  CustomTextField(
                    title: 'IBAN',
                    hintText: 'DE89370400440532013000',
                    controller: _manualIbanController,
                  ),
                  const SizedBox(height: 12),
                  CustomFilledButton(
                    title: 'Continue to pay',
                    onPressed: _onManualContinue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the camera can't be used (permission denied or unsupported):
/// falls back to manual IBAN entry so scan-to-pay still works.
class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.controller, required this.onContinue});

  final TextEditingController controller;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightBackgroundColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.no_photography_outlined, size: 48, color: greyColor),
          const SizedBox(height: 16),
          Text(
            'Camera unavailable',
            textAlign: TextAlign.center,
            style: blackTextStyle.copyWith(fontSize: 20, fontWeight: semiBold),
          ),
          const SizedBox(height: 8),
          Text(
            'Grant camera access, or enter the recipient IBAN below.',
            textAlign: TextAlign.center,
            style: greyTextStyle.copyWith(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            title: 'Recipient IBAN',
            hintText: 'DE89370400440532013000',
            controller: controller,
          ),
          const SizedBox(height: 20),
          CustomFilledButton(title: 'Continue to pay', onPressed: onContinue),
        ],
      ),
    );
  }
}
