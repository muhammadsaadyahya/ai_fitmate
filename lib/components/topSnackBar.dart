import "package:flutter/material.dart";
import "package:awesome_snackbar_content/awesome_snackbar_content.dart";

void showAwesomeSnackBar(BuildContext context, String message, ContentType type) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.only(top: 10, left: 12, right: 12),
    padding: EdgeInsets.zero,
    content: AwesomeSnackbarContent(
      title: '',
      message: message,
      contentType: type,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
