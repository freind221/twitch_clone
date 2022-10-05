import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Message {
  static toatsMessage(String message) {
    Fluttertoast.showToast(msg: message);
  }

  static Future pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      if (kIsWeb) {
        Uint8List fileBytes = result.files.single.bytes!;
        return fileBytes;
      }
      Uint8List file = await File(result.files.single.path!).readAsBytes();
      return file;
    }
  }
}
