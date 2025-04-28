import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseStorageProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

class FirebaseStorageService {
  Future<String?> uploadMedia(File mediaFile, {required bool isVideo}) async {
    try {
      final folder = isVideo ? 'videos' : 'images';
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${mediaFile.path.split('/').last}';
      final storageRef = FirebaseStorage.instance.ref().child(
          'Media/${FirebaseAuth.instance.currentUser!.uid.toString()}/$folder/$fileName');

      final uploadTask = storageRef.putFile(mediaFile);
      await uploadTask;

      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading to Firebase Storage: $e");
      }
      return null;
    }
  }
}
