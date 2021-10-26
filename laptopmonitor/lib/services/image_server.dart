import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:laptopmonitor/constants/camera_FPS.dart';
import 'package:laptopmonitor/services/camera_feed_service.dart';

class ImageServer {
  //this is going to get images and send them over to a local server
  //it needs the cameraFeedService
  //a function for getting data from the feed every x seconds
  //a function to sending over the image gotten to the server

  bool started;
  final CameraFeedService _cameraFeedService;
  List<Uint8List> _currentRawImageData;

  ImageServer(this._cameraFeedService)
      : _currentRawImageData = [],
        started = false;

  //starts recording and sending ovwer data
  Future<void> start() async {
    if (started) return;
    started = true;
    // while (true) {
    bool value = await grabImagesForSession(const Duration(seconds: 1));
    if (value) {
      Uri imageServerLink = Uri.parse("http://localhost:3000/image-batch/");
      var response = await http.post(imageServerLink,
          headers: {"Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "GET,PUT,POST,DELETE,PATCH,OPTIONS"},
          body: {"imageData": jsonEncode(_currentRawImageData ?? "Hi")});
      print("completed 1 session?: ${response.statusCode} ${response.body}");
    }

    // }
  }

  Future<bool> grabImagesForSession(Duration sessionLength) async {
    int frameCount = 0;
    _currentRawImageData.clear();

    //calculating the total frames needed
    int totalFrames = sessionLength.inSeconds * CameraFPS.kAmetekusMacCamera;
    while (frameCount <= totalFrames) {
      //this grabs the frame
      Uint8List? rawData = (await _cameraFeedService.captureCameraFeedFrame())?.asUint8List();
      if (rawData == null) {
        throw "FrameCaptureErrorInImageServer";
      } else {
        //appends the frame to the list of frames
        _currentRawImageData.add(rawData);
        // print("added: ${rawData.length}");
      }
      //increment
      frameCount++;
    }

    print("Finished a session with ${_currentRawImageData.length}");
    return true;
  }

  //make connection to server;
  //if successful, send either frame by frame or FPS by FPS
  Future<void> sendFramesToServer() async {}
}
