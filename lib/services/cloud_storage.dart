import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();
  FirebaseStorage _storage;
  String _profileImage = 'profile_image';

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
  }

  Future<String> uploadProfileImage({String uid, File image}) async {
    try {
      await _storage.ref().child(_profileImage).child(uid).putFile(image);

      String url = await _storage.ref('$_profileImage/$uid').getDownloadURL();
      return url;
    } catch (e) {
      print(e);
    }
  }
}
