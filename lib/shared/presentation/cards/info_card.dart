import 'package:flutter/material.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InfoCard extends StatelessWidget {
  final String header;
  final Map<String, String> values;

  const InfoCard({super.key, required this.header, required this.values});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: EdgeInsets.all(sizeS),
      title: Text(header, style: ShadTheme.of(context).textTheme.h4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: sizeXS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: values.entries
              .map(
                (entry) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: ShadTheme.of(context).textTheme.small,
                    ),
                    Text(
                      entry.value,
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
