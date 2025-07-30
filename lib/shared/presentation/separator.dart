import 'package:flutter/material.dart';
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
            thickness: 2,
            radius: ShadTheme.of(context).radius,
          )
        : ShadSeparator.vertical(
            thickness: 2,
            radius: ShadTheme.of(context).radius,
          );
  }
}
