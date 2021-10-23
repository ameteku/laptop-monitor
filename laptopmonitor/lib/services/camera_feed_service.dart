import 'package:camera/camera.dart';

class CameraFeed {
  final CameraController controller;

  CameraFeed({required this.controller});

  void recordVideo() {
    XFile? recordedVideo;
    controller.startVideoRecording();

    Future.delayed(Duration(microseconds: 100), () async {
      recordedVideo = await controller.stopVideoRecording();
    });

    if (recordedVideo != null) {
      // recordedVideo.saveTo(path)
    }
  }
}
