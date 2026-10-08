import 'package:flutter/material.dart';


class CustomSnackbar {
  static void show(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    final snackbar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      duration: duration,
      // backgroundColor: buttonColors,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );

    Future.delayed(Duration.zero, () {
      if (context.mounted) {
        CustomSnackbar.show(context, "Message");
      }
    });
  }
}
