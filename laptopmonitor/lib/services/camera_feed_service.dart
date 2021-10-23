import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';

class CameraFeed {
  //final CameraController controller;
  final MediaStreamTrack streamTrack;
  CameraFeed({
    required this.streamTrack,
  });

  //this captures a frame from the cam feed and returns a bytebuffer of the frame
  Future<ByteBuffer> captureCameraFeedFrame() async {
    return await streamTrack.captureFrame().then((value) => value);
  }

  Stream<ByteBuffer> createCameraBufferStream() async* {
    StreamSink<ByteBuffer> bufferSink;
  }
}
