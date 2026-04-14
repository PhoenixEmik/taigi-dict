import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showGlassNotification(
  BuildContext context, {
  required String message,
  bool isError = false,
  Duration duration = const Duration(milliseconds: 2600),
}) {
  if (message.isEmpty) {
    return;
  }

  AdaptiveSnackBar.show(
    context,
    message: message,
    type: isError
        ? AdaptiveSnackBarType.error
        : AdaptiveSnackBarType.success,
    duration: duration,
  );
}
