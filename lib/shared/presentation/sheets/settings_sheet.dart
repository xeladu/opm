import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/shared/presentation/sheet.dart';
import 'package:open_password_manager/shared/presentation/settings/color_scheme_setting.dart';
import 'package:open_password_manager/shared/presentation/settings/theme_mode_setting.dart';
import 'package:open_password_manager/style/ui.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Sheet(
      title: "App Settings",
      description: "Customize your app experience.",
      primaryButtonCaption: "Close",
      hideSecondaryButton: true,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: sizeS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: sizeS,
            children: [ColorSchemeSetting(), ThemeModeSetting()],
          ),
        ),
      ),
    );
  }
}
