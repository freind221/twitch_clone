import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  //Here we created an instance of firebaseStorage
  final FirebaseStorage _storage = FirebaseStorage.instance;

  uploadImageToSource(String childName, Uint8List file, String uid) async {
    //Reference ref = _storage.ref().child(childName).child(uid);
    Reference reference = FirebaseStorage.instance
        .ref('/FolderImages${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask =
        reference.putData(file, SettableMetadata(contentType: 'image/jpg'));
    TaskSnapshot snapshot = await uploadTask;
    var stringUrl = await snapshot.ref.getDownloadURL();
    return stringUrl;
  }
}
