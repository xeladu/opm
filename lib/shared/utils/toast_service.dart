import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ToastService {
  static void show(BuildContext context, String message) {
    ShadToaster.of(context).show(
      ShadToast(
        alignment: Alignment.bottomCenter,
        description: SizedBox(width: double.infinity, child: Text(message)),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        alignment: Alignment.bottomCenter,
        description: SizedBox(width: double.infinity, child: Text(message)),
      ),
    );
  }
}
