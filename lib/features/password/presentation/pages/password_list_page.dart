import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/password/infrastructure/providers/password_provider.dart';
import 'package:open_password_manager/style/sizes.dart';
import 'package:open_password_manager/features/password/application/use_cases/get_all_password_entries.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:uuid/uuid.dart';

class PasswordListPage extends ConsumerStatefulWidget {
  const PasswordListPage({super.key});

  @override
  ConsumerState<PasswordListPage> createState() => _State();
}

class _State extends ConsumerState<PasswordListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PasswordEntry> _allEntries = [];
  List<PasswordEntry> _filteredEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _searchController.addListener(_filterEntries);
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });
    final useCase = GetAllPasswordEntries(ref.read(passwordRepositoryProvider));
    final entries = await useCase();
    setState(() {
      _allEntries = entries;
      _filteredEntries = entries;
      _isLoading = false;
    });
  }

  void _filterEntries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEntries = _allEntries.where((entry) {
        return entry.name.toLowerCase().contains(query) ||
            entry.user.toLowerCase().contains(query) ||
            entry.urls.any((url) => url.toLowerCase().contains(query));
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passwords')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(sizeXS),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredEntries.isEmpty
                      ? const Center(child: Text('No entries found.'))
                      : ListView.builder(
                          itemCount: _filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredEntries[index];
                            return ListTile(
                              title: Text(entry.name),
                              subtitle: Text(entry.user),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (entry.urls.isNotEmpty) Icon(Icons.link),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            _EditPasswordEntryDialog(
                                              entry: entry,
                                              onSave: (updatedEntry) async {
                                                final repo = ref.read(
                                                  passwordRepositoryProvider,
                                                );
                                                await repo.editPasswordEntry(
                                                  updatedEntry,
                                                );
                                                await _loadEntries();
                                              },
                                            ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
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
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text('Delete'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final repo = ref.read(
                                          passwordRepositoryProvider,
                                        );
                                        await repo.deletePasswordEntry(
                                          entry.id,
                                        );
                                        await _loadEntries();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => _AddPasswordEntryDialog(
              onSave: (entry) async {
                final repo = ref.read(passwordRepositoryProvider);
                await repo.addPasswordEntry(entry);
                await _loadEntries();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddPasswordEntryDialog extends StatefulWidget {
  final Future<void> Function(PasswordEntry) onSave;
  const _AddPasswordEntryDialog({required this.onSave});

  @override
  State<_AddPasswordEntryDialog> createState() =>
      _AddPasswordEntryDialogState();
}

class _AddPasswordEntryDialogState extends State<_AddPasswordEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlsController = TextEditingController();
  final _commentsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _urlsController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Password Entry'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'User'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextFormField(
                controller: _urlsController,
                decoration: const InputDecoration(
                  labelText: 'URLs (semicolon separated)',
                ),
              ),
              TextFormField(
                controller: _commentsController,
                decoration: const InputDecoration(labelText: 'Comments'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final now = DateTime.now();
              final entry = PasswordEntry(
                id: const Uuid().v4(),
                name: _nameController.text,
                createdAt: now,
                updatedAt: now,
                user: _userController.text,
                password: _passwordController.text,
                urls: _urlsController.text
                    .split(';')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
                comments: _commentsController.text,
              );
              await widget.onSave(entry);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditPasswordEntryDialog extends StatefulWidget {
  final PasswordEntry entry;
  final Future<void> Function(PasswordEntry) onSave;
  const _EditPasswordEntryDialog({required this.entry, required this.onSave});

  @override
  State<_EditPasswordEntryDialog> createState() =>
      _EditPasswordEntryDialogState();
}

class _EditPasswordEntryDialogState extends State<_EditPasswordEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late TextEditingController _urlsController;
  late TextEditingController _commentsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.name);
    _userController = TextEditingController(text: widget.entry.user);
    _passwordController = TextEditingController(text: widget.entry.password);
    _urlsController = TextEditingController(text: widget.entry.urls.join(';'));
    _commentsController = TextEditingController(text: widget.entry.comments);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _urlsController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Password Entry'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'User'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextFormField(
                controller: _urlsController,
                decoration: const InputDecoration(
                  labelText: 'URLs (semicolon separated)',
                ),
              ),
              TextFormField(
                controller: _commentsController,
                decoration: const InputDecoration(labelText: 'Comments'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final updatedEntry = widget.entry.copyWith(
                name: _nameController.text,
                user: _userController.text,
                password: _passwordController.text,
                urls: _urlsController.text
                    .split(';')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
                comments: _commentsController.text,
              );
              await widget.onSave(updatedEntry);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
