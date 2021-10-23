import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<void> createAndShowDynamic(String data, BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Scan QR code with your app"),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * .5,
        width: MediaQuery.of(context).size.width * .5,
        child: Center(
          child: QrImage(
            data: data,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    ),
  );
}
