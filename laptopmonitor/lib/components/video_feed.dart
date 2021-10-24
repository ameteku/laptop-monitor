import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:laptopmonitor/services/camera_feed_service.dart';
import 'package:laptopmonitor/services/image_server.dart';

class VideoMediaDisplay extends StatefulWidget {
  VideoMediaDisplay({Key? key}) : super(key: key);

  @override
  State<VideoMediaDisplay> createState() => _VideoMediaDisplayState();
}

class _VideoMediaDisplayState extends State<VideoMediaDisplay> {
  CameraDescription? camera;
  CameraController? _controller;
  String _cameraStatus = "hi";
  bool _showVideoFeed = false;
  CameraPreview? preview;
  final _localRenderer = RTCVideoRenderer();
  CameraFeedService? cameraFeedService;
  Image? capturedImage;
  ImageServer? server;

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
      //cameraFeedService = CameraFeedService(mediaStream: _controller. );

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
    //  initializeCamera();
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

    //casting the web implementation of MediaStream
    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);

    _localRenderer.srcObject = stream;
    cameraFeedService = CameraFeedService(mediaStream: stream);
    server = ImageServer(cameraFeedService!);
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
            Future.delayed(Duration(seconds: 2), () => server!.start());
            return Column(
              children: [
                Switch(
                    value: _showVideoFeed,
                    onChanged: (value) async {
                      Uint8List imageBlob = await cameraFeedService!
                          .captureCameraFeedFrame()
                          .then((value) => value!.asUint8List())
                          .catchError((error, stackTrace) => print("Error ${error.toString()}"));

                      _cameraStatus = imageBlob.toString();
                      capturedImage = Image.memory(imageBlob);
                      print("Frame captured is $_cameraStatus");

                      // await cameraFeedService!.recordFiveSecondVideoStream();
                      setState(() {
                        _showVideoFeed = value;
                      });
                    }),
                //later on change to use visibility widget to make video disappear
                _showVideoFeed
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * .3,
                        width: MediaQuery.of(context).size.width * .3,
                        child: RTCVideoView(_localRenderer))
                    : capturedImage != null
                        ? capturedImage!
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
