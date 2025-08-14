import 'package:flutter/material.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Loading extends StatelessWidget {
  final String? text;

  const Loading({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(sizeXL),
      child: Column(
        spacing: sizeS,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text ?? "Loading ..."),
          SizedBox(height: 10, child: ShadProgress()),
        ],
      ),
    );
  }
}
