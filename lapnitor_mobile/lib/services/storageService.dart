import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StorageService {
  late firebase_storage.FirebaseStorage _storage;
  StorageService() : _storage = firebase_storage.FirebaseStorage.instance;

  Future<String> getDownloadUrlFromRelativePath(String path) => _storage.ref(path).getDownloadURL();

  Future<Uint8List?> getFileFromRelativePath(String path) => _storage.ref(path).getData();
}
