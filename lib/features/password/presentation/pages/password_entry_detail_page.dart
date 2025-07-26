import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/presentation/widgets/password_entry_details.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:open_password_manager/style/ui.dart';

class PasswordEntryDetailPage extends ConsumerWidget {
  final PasswordEntry entry;
  const PasswordEntryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveAppFrame(
      title: entry.name,
      content: Padding(
        padding: const EdgeInsets.all(sizeXS),
        child: PasswordEntryDetails(entry: entry),
      ),
    );
  }
}
