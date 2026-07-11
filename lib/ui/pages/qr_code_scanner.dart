import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_page.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/utils/iban_utils.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scan-to-pay: reads a payment QR (containing an IBAN) with the device or
/// browser camera, or falls back to manual IBAN entry in the panel below.
/// Camera and manual entry live in separate regions so they never overlap.
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
    return Scaffold(
      appBar: AppBar(title: const Text('Scan & pay')),
      body: Column(
        children: [
          // --- Camera region -------------------------------------------------
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                    errorBuilder: (context, error, child) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Camera unavailable. Allow camera access, or enter the IBAN below.',
                          textAlign: TextAlign.center,
                          style:
                              whiteTextStyle.copyWith(fontSize: 14, height: 1.4),
                        ),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ValueListenableBuilder<TorchState>(
                      valueListenable: _controller.torchState,
                      builder: (context, state, _) => IconButton(
                        icon: Icon(state == TorchState.on
                            ? Icons.flash_on
                            : Icons.flash_off),
                        color: whiteColor,
                        onPressed: () => _controller.toggleTorch(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // --- Manual entry region (separate, never overlaps camera) --------
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: whiteColor,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Point the camera at a payment QR',
                      textAlign: TextAlign.center,
                      style: blackTextStyle.copyWith(
                          fontSize: 15, fontWeight: semiBold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'or enter the recipient IBAN',
                      textAlign: TextAlign.center,
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      title: 'IBAN',
                      hintText: 'DE89 3704 0044 0532 0130 00',
                      controller: _manualIbanController,
                    ),
                    const SizedBox(height: 14),
                    CustomFilledButton(
                      title: 'Continue to pay',
                      onPressed: _onManualContinue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
