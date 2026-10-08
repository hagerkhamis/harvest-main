// snackbar_helper.dart
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

import 'package:hatvest/main.dart';

enum SnackbarType { success, error, info }

void showAwesomeSnackBar({
  required String title,
  required String message,
  required SnackbarType type,
}) {
  ContentType contentType;
  switch (type) {
    case SnackbarType.success:
      contentType = ContentType.success;
      break;
    case SnackbarType.error:
      contentType = ContentType.failure;
      break;
    case SnackbarType.info:
      contentType = ContentType.help;
      break;
  }

  scaffoldMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
            top: 20, left: 10, right: 10), // ✅ top position
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: contentType,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
}
