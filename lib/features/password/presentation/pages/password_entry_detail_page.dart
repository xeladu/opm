import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/infrastructure/providers/password_provider.dart';
import 'package:open_password_manager/features/password/presentation/pages/edit_password_entry_page.dart';

class PasswordEntryDetailPage extends ConsumerWidget {
  final PasswordEntry entry;
  const PasswordEntryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () async {
              final updatedEntry = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditPasswordEntryPage(
                    entry: entry,
                    onSave: (updated) async {
                      final repo = ref.read(passwordRepositoryProvider);
                      await repo.editPasswordEntry(updated);
                    },
                  ),
                ),
              );
              if (updatedEntry != null) {
                Navigator.of(context).pop(updatedEntry);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Entry'),
                  content: const Text(
                    'Are you sure you want to delete this password entry?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final repo = ref.read(passwordRepositoryProvider);
                await repo.deletePasswordEntry(entry.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(title: const Text('Name'), subtitle: Text(entry.name)),
            ListTile(
              title: const Text('Username'),
              subtitle: Text(entry.username),
            ),
            ListTile(
              title: const Text('Password'),
              subtitle: SelectableText(entry.password),
            ),
            ListTile(
              title: const Text('URLs'),
              subtitle: Text(entry.urls.join('\n')),
            ),
            ListTile(
              title: const Text('Comments'),
              subtitle: Text(entry.comments),
            ),
            ListTile(
              title: const Text('Created At'),
              subtitle: Text(entry.createdAt.toString()),
            ),
            ListTile(
              title: const Text('Updated At'),
              subtitle: Text(entry.updatedAt.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
