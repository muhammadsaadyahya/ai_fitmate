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

void showLoadingSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    duration: const Duration(seconds: 5), // or whatever duration you want
    margin: const EdgeInsets.only(top: 10, left: 12, right: 12),
    padding: EdgeInsets.zero,
    content: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCDFF00)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}