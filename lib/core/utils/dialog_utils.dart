import 'dart:async';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

dynamic _normalizeAdaptiveDialogIcon(dynamic icon) {
  if (icon is IconData || icon is String || icon == null) {
    return icon;
  }
  if (icon is Icon) {
    return icon.icon;
  }
  return null;
}

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String cancelLabel,
  required String confirmLabel,
  bool barrierDismissible = true,
  bool isDestructiveAction = false,
  dynamic icon,
  double? iconSize,
  Color? iconColor,
}) async {
  final result = Completer<bool>();
  final normalizedIcon = _normalizeAdaptiveDialogIcon(icon);

  final actions = [
    AlertAction(
      title: cancelLabel,
      style: isDestructiveAction
          ? AlertActionStyle.primary
          : AlertActionStyle.cancel,
      onPressed: () {
        if (!result.isCompleted) {
          result.complete(false);
        }
      },
    ),
    AlertAction(
      title: confirmLabel,
      style: isDestructiveAction
          ? AlertActionStyle.destructive
          : AlertActionStyle.primary,
      onPressed: () {
        if (!result.isCompleted) {
          result.complete(true);
        }
      },
    ),
  ];

  if (normalizedIcon != null) {
    await AdaptiveAlertDialog.show(
      context: context,
      title: title,
      message: content,
      icon: normalizedIcon,
      iconSize: iconSize,
      iconColor: iconColor,
      actions: actions,
    );
  } else {
    await AdaptiveAlertDialog.show(
      context: context,
      title: title,
      message: content,
      actions: actions,
    );
  }

  if (!result.isCompleted) {
    return false;
  }

  return result.future;
}

Future<VoidCallback> showAdaptiveBlockingProgressDialog({
  required BuildContext context,
  required String title,
  String? message,
  required String actionLabel,
  dynamic icon,
  double? iconSize,
  Color? iconColor,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  var closed = false;
  final normalizedIcon = _normalizeAdaptiveDialogIcon(icon);

  final actions = [
    AlertAction(
      title: actionLabel,
      enabled: false,
      style: AlertActionStyle.disabled,
      onPressed: () {},
    ),
  ];

  if (normalizedIcon != null) {
    unawaited(
      AdaptiveAlertDialog.show(
        context: context,
        title: title,
        message: message,
        icon: normalizedIcon,
        iconSize: iconSize,
        iconColor: iconColor,
        actions: actions,
      ),
    );
  } else {
    unawaited(
      AdaptiveAlertDialog.show(
        context: context,
        title: title,
        message: message,
        actions: actions,
      ),
    );
  }

  await Future<void>.delayed(Duration.zero);

  return () {
    if (closed) {
      return;
    }

    closed = true;
    unawaited(navigator.maybePop());
  };
}
