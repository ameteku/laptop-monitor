import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:laptopmonitor/services/camera_feed_service.dart';
import 'package:laptopmonitor/services/image_server.dart';
import 'package:laptopmonitor/utility_functions/debugMode.dart' as custom_debug;
import 'package:rxdart/rxdart.dart';

class VideoMediaDisplay extends StatefulWidget {
  bool shouldRecord;
  late final BehaviorSubject<ImageServer?> imageServer;
  VideoMediaDisplay({Key? key, required this.shouldRecord, required this.imageServer}) : super(key: key);

  @override
  State<VideoMediaDisplay> createState() => _VideoMediaDisplayState();
}

class _VideoMediaDisplayState extends State<VideoMediaDisplay> {
  CameraDescription? camera;
  CameraController? _controller;
  String _cameraStatus = "hi";
  bool _showVideoFeed = false;
  CameraPreview? preview;
  late final _localRenderer;
  CameraFeedService? cameraFeedService;
  Image? capturedImage;
  int initCamCallCount = 0;

  //this initializes the camera in the camera plugin
  Future<bool> initializeCamera() async {
    initCamCallCount++;
    debugPrint("Called: $initCamCallCount");
    // Obtain a list of the available cameras on the device.
    if (_controller != null) {
      custom_debug.debugPrint("Controller is not null");
      return true;
    }
    await availableCameras().then((value) async {
      setState(() {
        _cameraStatus = value.toString();
      });
      camera = value.first;

      _controller = CameraController(camera!, ResolutionPreset.medium);
      await _controller!.initialize();
      preview = CameraPreview(_controller!);
      //cameraFeedService = CameraFeedService(mediaStream: _controller. );

      setState(() {
        _cameraStatus = "Camera is On";
      });
      return true;
    }).onError((error, stackTrace) {
      print("initialize cam error: $error");
      setState(() {
        _cameraStatus = error.toString() + stackTrace.toString();
      });
      return false;
    });
    print("_controller is null : $_controller");

    return false;
  }

  //gets the camera and audio source from device
  _getUserMediaPermissions() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': {"facingMode": "user"}
    };

    //getting permission form browser
    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);

    _localRenderer.srcObject = stream;
    cameraFeedService = CameraFeedService(mediaStream: stream);
    widget.imageServer.add(ImageServer(cameraFeedService!));
  }

  void initRenderer() async {
    _localRenderer = RTCVideoRenderer();
    await _localRenderer.initialize();
  }

  @override
  void initState() {
    //  initializeCamera();
    initRenderer();
    _getUserMediaPermissions();
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
              return Text(_cameraStatus);
            }
            return Column(
              children: [
                //later on change to use visibility widget to make video disappear
                _showVideoFeed
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * .3,
                        width: MediaQuery.of(context).size.width * .3,
                        child: RTCVideoView(_localRenderer))
                    //child: Icon(Icons.camera))
                    : const Text("Camera is Recording"),
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
