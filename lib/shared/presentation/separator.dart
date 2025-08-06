import 'package:flutter/material.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Separator extends StatelessWidget {
  final bool horizontal;

  const Separator._({super.key, required this.horizontal});

  const Separator.horizontal({Key? key}) : this._(key: key, horizontal: true);
  const Separator.vertical({Key? key}) : this._(key: key, horizontal: false);

  @override
  Widget build(BuildContext context) {
    return horizontal
        ? ShadSeparator.horizontal(
            thickness: sizeXXXS,
            radius: ShadTheme.of(context).radius,
          )
        : ShadSeparator.vertical(
            thickness: sizeXXXS,
            radius: ShadTheme.of(context).radius,
          );
  }
}
