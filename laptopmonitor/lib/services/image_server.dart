import 'dart:typed_data';

import 'package:laptopmonitor/services/camera_feed_service.dart';

class ImageServer {
  //this is going to get images and send them over to a local server
  //it needs the cameraFeedService
  //a function for getting data from the feed every x seconds
  //a function to sending over the image gotten to the server

  final CameraFeedService _cameraFeedService;
  List<Uint8List> _currentRawImageData;

  ImageServer(this._cameraFeedService) : _currentRawImageData = [];

  void grabImagesForSession(Duration sessionLength) {
    Duration count = Duration.zero;
  }
}
