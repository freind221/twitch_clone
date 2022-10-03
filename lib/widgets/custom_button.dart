import 'package:flutter/material.dart';
import 'package:twitch_clone/utilis/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {Key? key, required this.onTap, required this.text, this.loading = false})
      : super(key: key);
  final String text;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: buttonColor,
        minimumSize: const Size(double.infinity, 40),
      ),
      onPressed: onTap,
      child: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Text(text),
    );
  }
}
