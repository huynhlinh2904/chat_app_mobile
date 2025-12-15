import 'package:flutter/material.dart';

class ToastService {
  static void show(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 2),
        Color backgroundColor = Colors.black87,
      }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}
