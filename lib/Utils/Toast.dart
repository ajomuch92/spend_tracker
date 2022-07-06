import 'package:flutter/material.dart';

void showToast(BuildContext context, String text, {
    String buttonLabel = 'Ok',
    Duration duration = const Duration(seconds: 3),
    DismissDirection dismissDirection = DismissDirection.down,
    ToastStatus toastStatus = ToastStatus.none
  }) {
  final scaffold = ScaffoldMessenger.of(context);
  Color? textColor = getTextColor(toastStatus);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: buttonLabel,
        onPressed: scaffold.hideCurrentSnackBar,
        textColor: textColor
      ),
      duration: duration,
      dismissDirection: dismissDirection,
    ),
  );
}

Color? getTextColor(ToastStatus toastStatus) {
  switch(toastStatus) {
    case ToastStatus.success:
      return Colors.greenAccent;
    case ToastStatus.warning:
      return Colors.yellow;
    case ToastStatus.error:
      return Colors.redAccent;
    case ToastStatus.info:
      return Colors.blueAccent;
    default:
      return null;
  }
}

enum ToastStatus {
  none,
  info,
  warning,
  error,
  success
}