import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ReadQRcode extends StatefulWidget {
  const ReadQRcode({Key? key}) : super(key: key);

  @override
  State<ReadQRcode> createState() => _ReadQRcodeState();
}

class _ReadQRcodeState extends State<ReadQRcode> {
  String? qrCodeStr;
  final qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? qrViewController;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrViewController!.pauseCamera();
    } else if (Platform.isIOS) {
      qrViewController!.resumeCamera();
    }
  }

  @override
  void dispose() {
    qrViewController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Container(
          margin: const EdgeInsets.all(16),
          width: constraints.maxWidth * 0.3,
          height: constraints.maxWidth * 0.3,
          child: QRView(
            key: qrKey,
            onQRViewCreated: (p0) {
              qrViewController = p0;
              qrViewController!.scannedDataStream.listen((event) async {
                qrCodeStr ??= event.code;
                print('##27July qrCodeStr ==> $qrCodeStr');
              });
            },
          ),
        ),
      ),
    );
  }
}
