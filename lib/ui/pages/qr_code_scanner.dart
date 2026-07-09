import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_page.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/utils/iban_utils.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final TextEditingController _manualIbanController = TextEditingController();
  QRViewController? controller;
  bool _flashOn = false;
  bool _handled = false;

  @override
  void dispose() {
    controller?.dispose();
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

  void _onManualContinue() => _openTransfer(_manualIbanController.text);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildManualEntry(scaffold: true);
    }

    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              overlayColor: const Color(0x55000000),
              borderColor: Colors.white,
              borderRadius: 24,
              cutOutSize: MediaQuery.of(context).size.width * 0.75,
              borderWidth: 10,
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              color: whiteColor,
              iconSize: 28,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
              icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
              color: whiteColor,
              iconSize: 28,
              onPressed: () {
                setState(() => _flashOn = !_flashOn);
                controller?.toggleFlash();
              },
            ),
          ),
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
                    'Scan a payment QR code',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Or enter the IBAN manually',
                    style: greyTextStyle.copyWith(fontSize: 13),
                  ),
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

  Widget _buildManualEntry({required bool scaffold}) {
    final body = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pay with IBAN',
            style: blackTextStyle.copyWith(fontSize: 20, fontWeight: semiBold),
          ),
          const SizedBox(height: 8),
          Text(
            'Camera scanning is unavailable on web. Paste or type the recipient IBAN.',
            style: greyTextStyle.copyWith(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            title: 'Recipient IBAN',
            hintText: 'DE89370400440532013000',
            controller: _manualIbanController,
          ),
          const SizedBox(height: 24),
          CustomFilledButton(
            title: 'Continue to pay',
            onPressed: _onManualContinue,
          ),
        ],
      ),
    );

    if (!scaffold) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan & Pay')),
      body: body,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      final code = scanData.code?.trim();
      if (code == null || code.isEmpty || _handled) return;
      _handled = true;
      controller.pauseCamera();
      if (!mounted) return;
      _openTransfer(code);
    });
  }
}
