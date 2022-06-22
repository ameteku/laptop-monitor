import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:lapnitor_mobile/models/Event.dart';

class EventStreamController extends ChangeNotifier {
  final Stream<List<Event>> _stream;
  List<Event> _updatedEvents;
  bool newData = false;

  EventStreamController(this._stream) : _updatedEvents = [] {
    _stream.listen((events) {
      _updatedEvents = events;
      newData = true;
      notifyListeners();
    });
  }

  List<Event> getUpdatedList() {
    newData = false;
    return _updatedEvents;
  }
}
