import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  Event(this.activity, this.evidenceUrl, this.time, this.distanceFromCamera);
  String activity;
  String evidenceUrl;
  Timestamp time;
  double? distanceFromCamera;

  @override
  String toString() => "Event{activity: $activity, evidenceUrl:$evidenceUrl, time: $time";
}
