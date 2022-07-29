import 'dart:io';

import 'package:admanyout/states/detail_post_link.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_text.dart';
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
  bool firstReadQrcode = false;

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
        builder: (context, constraints) => Column(
          children: [
            newScan(constraints),
            ShowText(
              label: 'Please Tap ScreenBack for Scan',
              textStyle: MyConstant().h3BlackStyle(),
            ),
            ShowText(
              label: 'กรุณา แตะ หน้าจอ สำหรับสแกน',
              textStyle: MyConstant().h3BlackStyle(),
            ),
            ShowForm(
              colorTheme: Colors.black,
              label: 'Code',
              iconData: Icons.qr_code,
              changeFunc: (p0) {},
            )
          ],
        ),
      ),
    );
  }

  Row newScan(BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          width: constraints.maxWidth,
          height: constraints.maxHeight * 0.5,
          child: QRView(
            key: qrKey,
            onQRViewCreated: (p0) {
              qrViewController = p0;
              qrViewController!.scannedDataStream.listen((event) async {
                if (!firstReadQrcode) {
                  firstReadQrcode = true;
                  qrCodeStr ??= event.code;
                  print('##27july qrCodeStr ==> $qrCodeStr');
                  // qrViewController!.stopCamera();

                  if (qrCodeStr?.isNotEmpty ?? false) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPostLink(linkId: qrCodeStr!),
                        ),
                        (route) => false);
                  }
                }
              });
            },
          ),
        ),
      ],
    );
  }
}
