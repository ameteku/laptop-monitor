
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';


//class for setting processing camera streams
class CameraFeedService {
   CameraController? controller;
  final MediaStream? mediaStream;
  MediaStreamTrack? currentTrack;
  final MediaRecorder _mediaRecorder;

  CameraFeedService({
    required this.mediaStream,
  }) : _mediaRecorder = MediaRecorder() {
    currentTrack = mediaStream!.getVideoTracks().first;
    print("Assigning current track to ${currentTrack.toString()}");
  }

  //this captures a frame from the cam feed and returns a bytebuffer of the frame
  Future<ByteBuffer?> captureCameraFeedFrame() async {
    currentTrack?.enabled = true;
    ByteBuffer? data=  await currentTrack?.captureFrame().then((value) => value).catchError((error, stackTrace) {
      print("Error in capture image 22 : ${error.toString()} ${stackTrace.toString()}")});
    print("image captures is:" + (data).toString());
    return data;
  }

  startRecordingCameraFeed(Function actionOnData)async  {
    _mediaRecorder.startWeb(mediaStream!, onDataChunk: (chunk,isLast )=> actionOnData(chunk, isLast));
  }

  Future<dynamic> stopRecordingCameraFeed() async {
   dynamic data = await _mediaRecorder.stop();

   print("Data gotten from camera is ${data.runtimeType} ${data.toString()}");
   return data;
  }


  //not working
  recordFiveSecondVideoStream() async  {
    List<dynamic> dataChunks = [];
   await startRecordingCameraFeed((dynamic chunk, bool isLast) {
     print("adding chunk ${(chunk.toString())}");
     dataChunks.add(chunk);
   });

   await Future.delayed(const Duration(seconds: 5), () async => await stopRecordingCameraFeed());

   print("Chunks gotten: ${dataChunks.toString()}");

  }
}
