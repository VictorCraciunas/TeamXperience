import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ImageRepo{
  final storageRef = FirebaseStorage.instance.ref();

  Future<String?> uploadImage(File imageFile, String eventId, String imageType) async {
    try {
      final imageRef = storageRef.child('events/$eventId/$imageType.jpg');
      await imageRef.putFile(imageFile);
      return await imageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

}