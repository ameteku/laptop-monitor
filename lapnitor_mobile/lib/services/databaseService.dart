import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lapnitor_mobile/models/event.dart';

class DatabaseService {
  static const String sessionCollectionPath = "sessionId";
  static const String sessionResultsPath = "userResults";

  String? _laptopId = 'fghhdfsgdavbfd';
  bool isConnected = false;

  FirebaseFirestore db;

  DatabaseService() : db = FirebaseFirestore.instance;

  //arg: qrcode value gotten from scan
  //check in db for that value, if present
  Future<bool> connectDB(String laptopId) =>
      db.collection(sessionCollectionPath).where('id', isEqualTo: laptopId).limit(1).get().then((value) {
        if (value.size == 1) {
          isConnected = true;
          _laptopId = laptopId;
          return true;
        }
        return false;
      }).catchError((error) => false);

  get id => _laptopId;

  Stream<List<Event>>? getFeedStream() {
    if (_laptopId == null) return null;

    try {
      return db.collection(sessionResultsPath).where('laptopId', isEqualTo: _laptopId).snapshots().map((event) {
        if (event.size == 0) return [];
        dynamic e = event.docs[0].data()['1646186649719'];
        Event temp = Event("human Spotteed", e['imageLink'], e['timestamp']);
        print("event: $event");

        return [temp];
        // return event.docs[0].map((e) {
        //   return Event('Human Spotted', e['imageLink'], e['timestamp']);
        // }).toList();
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error: ${error}');
      }
    }
    return null;
  }
}
