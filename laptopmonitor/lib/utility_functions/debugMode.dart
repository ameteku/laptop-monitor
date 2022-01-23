import 'package:flutter/foundation.dart';

//Ensuring that print statements are only executed during debug mode
debugPrint(statement) {
  if (kDebugMode) {
    print(statement);
  }
}
