import 'package:flutter/material.dart';
import 'package:twitch_clone/utilis/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String message;
  final Function(String)? onTap;
  const CustomTextField(
      {Key? key, required this.controller, this.onTap, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        onFieldSubmitted: onTap,
        controller: controller,
        decoration: const InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: buttonColor,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: secondaryBackgroundColor,
              ),
            )),
        validator: (value) {
          if (message == 'Email' || message == 'email') {
            if (value!.isEmpty) {
              return "$message  cannat be empty";
            } else if (!value.contains('@') || !value.contains('.')) {
              return "Email is not Valid";
            }
          } else if (message == 'Password' || message == 'password') {
            if (value!.isEmpty) {
              return "$message  cannat be empty";
            }
          } else if (message == 'username' || message == 'Username') {
            if (value!.isEmpty) {
              return "$message  cannat be empty";
            }
          }
          return null;
        });
  }
}
