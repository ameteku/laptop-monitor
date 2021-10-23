import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraFeed extends StatefulWidget {
  CameraFeed({Key? key}) : super(key: key);

  @override
  State<CameraFeed> createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  CameraDescription? camera;
  CameraController? _controller;

  Future<CameraController?> initializeCamera() async {
    // Obtain a list of the available cameras on the device.
    await availableCameras().then((value) async {
      print("getting cameras $value");
      camera = value.first;
      _controller = CameraController(camera!, ResolutionPreset.medium);
      await _controller!.initialize();
      return _controller;
    }).onError((error, stackTrace) {
      print(error);
    });
    print("_controller is null");

    return _controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializeCamera(),
        builder: (context, AsyncSnapshot<CameraController?> snapshot) {
          print("In init ${snapshot.data}");
          if (snapshot.connectionState == ConnectionState.active) {
            return CameraPreview(_controller!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }
}
