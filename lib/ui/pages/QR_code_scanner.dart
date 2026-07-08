import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/navigation_utils.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_page.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _flashOn = false;
  String scannedText = "";

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebSafePopScope(
      child: Scaffold(
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
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 5,
                ),
              ),
              child: Center(
                child: Text(
                  'Scan any QR to Pay',
                  style: blackTextStyle.copyWith(fontSize: 18),
                ),
              ),
            ),
          ),
          Positioned(

            top: 40,
            right: 50,
            child: IconButton(
              icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
              color: whiteColor,
                            iconSize: 28,

              onPressed: () => setState(() {
                _flashOn = !_flashOn;
                if (controller != null) {
                  controller!.toggleFlash();
                }
              }),
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.qr_code_2_rounded),
                            iconSize: 28,
              color: whiteColor,
              onPressed: () => Navigator.of(context).pushNamed("/showAccountQR")
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
                            iconSize: 28,

              color: whiteColor,
              onPressed: () => popOrHome(context),
            ),
          ),
        ],
      ),
    ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedText = scanData.code!;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                TransferPage(receiverIban: scannedText),
          ),
        );
      });
    });
  }
}
