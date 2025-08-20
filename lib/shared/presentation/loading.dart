import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/shared/application/providers/loading_text_state_provider.dart';
import 'package:open_password_manager/shared/application/providers/loading_value_state_provider.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Loading extends ConsumerWidget {
  final String? text;
  final double? value;

  const Loading({super.key, this.text, this.value});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(sizeXL),
      child: Column(
        spacing: sizeS,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text ?? ref.watch(loadingTextStateProvider)),
          SizedBox(
            height: 10,
            child: ShadProgress(value: value ?? ref.watch(loadingValueStateProvider)),
          ),
        ],
      ),
    );
  }
}
