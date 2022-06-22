import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lapnitor_mobile/pages/switcher.dart';
import 'package:lapnitor_mobile/services/databaseService.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanPage extends StatefulWidget {
  final void Function(Pages) onSwitchPage;
  const ScanPage({Key? key, required this.onSwitchPage}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? qrValue = "::1";

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  QRStatus currentQRStatus = QRStatus.waiting;
  late DatabaseService dbService;

  @override
  void initState() {
    super.initState();
    dbService = context.read<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                selectText(currentQRStatus),
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  selectText(QRStatus currentStatus) {
    String statusText = 'Please Wait';
    switch (currentStatus) {
      case QRStatus.waiting:
        statusText = 'To connect,\nscan the qr code from your laptop';
        break;
      case QRStatus.processing:
        statusText = 'Trying to Connect';
        break;
      case QRStatus.success:
        statusText = 'Success!!🎉 You can head over to the activity page now';
        break;
      case QRStatus.error:
        statusText = 'There was an error, please crosscheck the code and scan again';
        break;
      default:
        break;
    }
    return statusText;
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    await tryConnecting();
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      setState(() {
        qrValue = scanData.code;
        currentQRStatus = QRStatus.processing;
      });

      await tryConnecting();
    });
  }

  Future<void> tryConnecting() async {
    bool isConnected = await dbService.connectDB(qrValue!);

    setState(() {
      if (isConnected) {
        currentQRStatus = QRStatus.success;
      } else {
        currentQRStatus = QRStatus.error;
      }
    });

    Future.delayed(const Duration(milliseconds: 10), () => widget.onSwitchPage(Pages.feedPage));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

enum QRStatus { waiting, processing, error, success }
