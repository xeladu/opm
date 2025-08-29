import 'package:flutter/material.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return GlyphButton.important(
      icon: LucideIcons.wifiOff,
      onTap: () async => await _showInfoDialog(context),
    );
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    await DialogService.showNoConnectionDialog(context);
  }
}
