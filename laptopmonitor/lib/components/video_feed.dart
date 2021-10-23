import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CameraFeed extends StatefulWidget {
  CameraFeed({Key? key}) : super(key: key);

  @override
  State<CameraFeed> createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  CameraDescription? camera;
  CameraController? _controller;
  String _cameraStatus = "hi";
  bool _showVideoFeed = false;
  CameraPreview? preview;
  final _localRenderer = RTCVideoRenderer();

  //this initializes the camera in the camera plugin
  Future<bool> initializeCamera() async {
    // Obtain a list of the available cameras on the device.
    if (_controller != null) return true;
    await availableCameras().then((value) async {
      print("getting cameras $value");
      setState(() {
        _cameraStatus = value.toString();
      });
      camera = value.first;
      _controller = CameraController(camera!, ResolutionPreset.medium);
      await _controller!.initialize();
      preview = CameraPreview(_controller!);
      setState(() {
        _cameraStatus = "Camera is Recording";
      });
      return true;
    }).onError((error, stackTrace) {
      print(error);
      setState(() {
        _cameraStatus = error.toString() + stackTrace.toString();
      });
      return false;
    });
    print("_controller is null");

    return false;
  }

  @override
  void initState() {
    // initializeCamera();

    initRenderer();
    _getUserMedia();
    super.initState();
  }

  //gets the camera and audio source from device
  _getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': {"facingMode": "user"}
    };

    MediaStream stream = await navigator.getUserMedia(constraints);
    _localRenderer.srcObject = stream;
  }

  void initRenderer() async {
    await _localRenderer.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializeCamera(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          print("In init ${snapshot.data}");
          if (snapshot.hasData) {
            if (snapshot.data == false) {
              return Text(_cameraStatus);
            }
            return Column(
              children: [
                Switch(
                    value: _showVideoFeed,
                    onChanged: (value) {
                      setState(() {
                        _showVideoFeed = value;
                      });
                    }),
                _showVideoFeed
                    ? Container(
                        height: MediaQuery.of(context).size.height * .3,
                        width: MediaQuery.of(context).size.width * .3,
                        child: RTCVideoView(_localRenderer))
                    : Text(_cameraStatus),
              ],
            );
          } else {
            return Center(
              child: Text(_cameraStatus),
            );
          }
        });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    if (_controller != null) _controller?.dispose();
    _localRenderer.dispose();
    super.dispose();
  }
}
