import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  Event(this.activity, this.evidenceUrl, this.time);
  String activity;
  String evidenceUrl;
  Timestamp time;

  @override
  String toString() => "Event{activity: $activity, evidenceUrl:$evidenceUrl, time: $time";
}
