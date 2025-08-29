import 'package:flutter/cupertino.dart';
import 'package:open_password_manager/shared/utils/log_service.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';

/// Runs UI code, handles exceptions, and cleanup
Future<void> runGuarded({
  required BuildContext context,
  required Future<void> Function() action,
  String? errorMessage,
  Future<void> Function()? onException,
  Future<void> Function()? onFinally,
  bool logExceptions = false,
}) async {
  try {
    await action();
  } on Exception catch (ex, st) {
    if (logExceptions) LogService.recordError(ex, st);
    if (onException != null) await onException();
    if (context.mounted) {
      ToastService.showError(context, errorMessage ?? "An unexpected error happened!");
    }
  } finally {
    if (onFinally != null) await onFinally();
  }
}
