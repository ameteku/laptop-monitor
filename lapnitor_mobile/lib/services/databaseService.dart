import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lapnitor_mobile/models/event.dart';

class DatabaseService {
  static const String sessionResultsPath = "userResults";
  static const String suspectImagesCollectionPath = "suspectImages";

  String? _laptopId;
  bool isConnected = false;

  FirebaseFirestore db;

  DatabaseService({laptopId}) : db = FirebaseFirestore.instance {
    _laptopId = laptopId;
  }

  //arg: qrcode value gotten from scan
  //check in db for that value, if present
  Future<bool> connectDB(String laptopId) => db.collection(sessionResultsPath).doc(laptopId).get().then((value) {
        print("DOc is ${value.data()}");
        if (value.data() != null && value.data()!["id"] == laptopId) {
          isConnected = true;
          _laptopId = laptopId;

          return true;
        }
        return false;
      }).catchError((error) {
        print("Error: $error");
        return false;
      });

  get id {
    print("getting laptopid>>> ${_laptopId}");
    return _laptopId;
  }

  Stream<List<Event>>? getFeedStream() {
    if (_laptopId == null) return null;

    print("Passed null stage");

    try {
      return db.collection(sessionResultsPath).doc(_laptopId).collection(suspectImagesCollectionPath).snapshots().map((events) {
        if (events.size == 0) return [];

        print("Events ${events.docs.length}");
        var items = events.docs.map((event) {
          var eventData = event.data();
          return Event(eventData["activityType"], eventData['imageLink'], eventData['timestamp'], eventData["distanceFromCamera"]);
        });
        print("Items are ${items.runtimeType}");
        return items.toList();
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error: ${error}');
      }
    }
    return null;
  }
}
