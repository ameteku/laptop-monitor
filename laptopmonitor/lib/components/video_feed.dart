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
  String text = "hi";

  Future<bool> initializeCamera() async {
    // Obtain a list of the available cameras on the device.
    if (_controller != null) return true;
    await availableCameras().then((value) async {
      print("getting cameras $value");
      setState(() {
        text = value.toString();
      });
      camera = value.first;
      _controller = CameraController(camera!, ResolutionPreset.medium);
      await _controller!.initialize();
      setState(() {
        text = "done initing controller";
      });
      return true;
    }).onError((error, stackTrace) {
      print(error);
      setState(() {
        text = error.toString() + stackTrace.toString();
      });
      return false;
    });
    print("_controller is null");

    return false;
  }

  @override
  void initState() {
    initializeCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializeCamera(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          print("In init ${snapshot.data}");
          if (snapshot.hasData) {
            if (snapshot.data == false) {
              return Text(text);
            }
            return CameraPreview(_controller!);
          } else {
            return Center(
              child: Text(text),
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
