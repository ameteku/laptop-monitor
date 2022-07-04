import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:laptopmonitor/constants/camera_FPS.dart';
import 'package:laptopmonitor/services/camera_feed_service.dart';
import 'package:laptopmonitor/utility_functions/debugMode.dart';
import 'package:rxdart/rxdart.dart';

class ImageServer {
  //this is going to get images and send them over to a local server
  //it needs the cameraFeedService
  //a function for getting data from the feed every x seconds
  //a function to sending over the image gotten to the server

  BehaviorSubject<bool> started;
  final CameraFeedService _cameraFeedService;
  List<Uint8List> _currentRawImageData;
  String kServerBaseLink = "http://localhost:3000";
  Map<String, String> headers = {
    "Access-Control-Allow-Origin": "www.lapnitor2.herokuapp.com",
    "Access-Control-Allow-Methods": "GET,PUT,POST,DELETE,PATCH,OPTIONS"
  };

  String? id;

  ImageServer(this._cameraFeedService)
      : _currentRawImageData = [],
        started = BehaviorSubject.seeded(false) {
    connectToServer();
  }

  //starts recording and sending owner data
  Future<void> startSending() async {
    if (started.value) return;
    started.add(true);
    while (started.value) {
      bool isSuccess = await grabImagesForSession(const Duration(seconds: 1));
      if (isSuccess) {
        debugPrint("Number of images grabbed: ${_currentRawImageData.length}");
        await sendFramesToServer();
      }
    }
  }

  Future<void> stopSending() async {
    started.add(false);
    debugPrint("Stopped sending and recording");
    _currentRawImageData.clear();
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
  Future<void> connectToServer() async {
    var response = await http.post(Uri.parse(kServerBaseLink + '/connect'), headers: headers);
    print("established connection? : ${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      id = jsonDecode(response.body)["id"];
    }
  }

  //if successful, send either frame by frame or FPS by FPS
  Future<void> sendFramesToServer() async {
    if (_currentRawImageData.isEmpty) return;
    var jsonData = {"frames": jsonEncode(_currentRawImageData), "id": id};
    var response = await http.post(Uri.parse(kServerBaseLink + '/addVideoFeed'), headers: headers, body: jsonData);
    print("completed 1 session?: ${response.statusCode} ${response.body}");
  }
}
