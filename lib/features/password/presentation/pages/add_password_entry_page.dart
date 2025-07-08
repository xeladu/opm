import 'package:flutter/material.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:uuid/uuid.dart';

class AddPasswordEntryPage extends StatefulWidget {
  final Future<void> Function(PasswordEntry) onSave;
  const AddPasswordEntryPage({required this.onSave, super.key});

  @override
  State<AddPasswordEntryPage> createState() => _AddPasswordEntryPageState();
}

class _AddPasswordEntryPageState extends State<AddPasswordEntryPage> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Password Entry')),
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
                        final now = DateTime.now();
                        final entry = PasswordEntry(
                          id: const Uuid().v4(),
                          name: _nameController.text,
                          createdAt: now,
                          updatedAt: now,
                          username: _userController.text,
                          password: _passwordController.text,
                          urls: _urlsController.text
                              .split(';')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                          comments: _commentsController.text,
                        );
                        await widget.onSave(entry);
                        if (context.mounted) {
                          Navigator.of(context).pop(entry);
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
