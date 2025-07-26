import 'package:flutter/material.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/presentation/widgets/empty_list.dart';
import 'package:open_password_manager/features/password/presentation/widgets/password_list_entry.dart';
import 'package:open_password_manager/features/password/presentation/widgets/password_search_field.dart';
import 'package:open_password_manager/style/ui.dart';

class PasswordListMobile extends StatelessWidget {
  final List<PasswordEntry> passwords;

  const PasswordListMobile({
    super.key,
    required this.passwords,
  });

  @override
  Widget build(BuildContext context) {
    if (passwords.isEmpty) {
      return Center(
        child: EmptyList(
          message: "Your vault is empty!\r\nStart by adding your first entry",
        ),
      );
    }

    final leftPanelContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${passwords.length} entries found"),
        SizedBox(height: sizeXS),
        PasswordSearchField(),
        SizedBox(height: sizeXS),
        Expanded(
          child: ListView.builder(
            itemCount: passwords.length,
            itemBuilder: (context, index) {
              final entry = passwords[index];
              return PasswordListEntry(
                entry: entry,
                selected: false,
                isMobile: true,
              );
            },
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(sizeS),
      child: leftPanelContent,
    );
  }
}
