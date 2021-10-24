import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CameraFeedService {
   CameraController? controller;
  final MediaStream? mediaStream;
  MediaStreamTrack? currentTrack;

  CameraFeedService({
    required this.mediaStream,
  }) {
    currentTrack = mediaStream!.getVideoTracks().first;
    print("Assigning current track to ${currentTrack.toString()}");
  }

  //this captures a frame from the cam feed and returns a bytebuffer of the frame
  Future<ByteData?> captureCameraFeedFrame() async {
    currentTrack?.enabled = true;
    ByteData? data=  await currentTrack?.captureFrame().then((value) => ByteData.view(value)).catchError((error, stackTrace) {
      print("Error in capture image 22 : ${error.toString()} ${stackTrace.toString()}")});
  }

  // Stream<ByteBuffer> createCameraBufferStream() async* {
  //   StreamSink<ByteBuffer> bufferSink = ;
  //
  //   yield bufferSink;
  // }
}
