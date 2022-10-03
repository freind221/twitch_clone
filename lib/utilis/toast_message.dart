import 'package:fluttertoast/fluttertoast.dart';

class Message {
  static toatsMessage(String message) {
    Fluttertoast.showToast(msg: message);
  }
}
