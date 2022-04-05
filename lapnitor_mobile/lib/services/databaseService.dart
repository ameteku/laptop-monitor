import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lapnitor_mobile/models/event.dart';

class DatabaseService {
  static const String sessionResultsPath = "userResults";
  static const String suspectImagesCollectionPath = "suspectImages";

  String? _laptopId = '::1';
  bool isConnected = false;

  FirebaseFirestore db;

  DatabaseService({laptopId}) : db = FirebaseFirestore.instance {
    if (laptopId != null) {
      _laptopId = _laptopId;
    }
  }

  //arg: qrcode value gotten from scan
  //check in db for that value, if present
  Future<bool> connectDB(String laptopId) => db.collection(sessionResultsPath).doc(_laptopId).get().then((value) {
        if (value.data() != null && value.data()!["id"] == _laptopId) {
          isConnected = true;
          _laptopId = laptopId;
          return true;
        }
        return false;
      }).catchError((error) {
        print("Error: $error");
        return false;
      });

  get id => _laptopId;

  Stream<List<Event>>? getFeedStream() {
    if (_laptopId == null) return null;

    try {
      return db.collection(sessionResultsPath).doc(_laptopId).collection(suspectImagesCollectionPath).snapshots().map((events) {
        if (events.size == 0) return [];
        return events.docs
            .map((event) => Event(event["activityType"], event['imageLink'], event['timestamp'], event["distanceFromCamera"]))
            .toList();
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error: ${error}');
      }
    }
    return null;
  }
}
