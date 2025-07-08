import 'package:flutter/material.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';

class EditPasswordEntryPage extends StatefulWidget {
  final PasswordEntry entry;
  final Future<void> Function(PasswordEntry) onSave;
  const EditPasswordEntryPage({required this.entry, required this.onSave, super.key});

  @override
  State<EditPasswordEntryPage> createState() => _EditPasswordEntryPageState();
}

class _EditPasswordEntryPageState extends State<EditPasswordEntryPage> {
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
    _userController = TextEditingController(text: widget.entry.username);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Password Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final updatedEntry = widget.entry.copyWith(
                          name: _nameController.text,
                          username: _userController.text,
                          password: _passwordController.text,
                          urls: _urlsController.text
                              .split(';')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                          comments: _commentsController.text,
                        );
                        await widget.onSave(updatedEntry);
                        if (context.mounted) {
                          Navigator.of(context).pop(updatedEntry);
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
