import 'package:flutter/material.dart';
import 'package:open_password_manager/style/sizes.dart';
import '../../application/use_cases/get_all_password_entries.dart';
import '../../infrastructure/repositories/firebase/firebase_password_repository_impl.dart';
import '../../domain/entities/password_entry.dart';

class PasswordListPage extends StatefulWidget {
  const PasswordListPage({super.key});

  @override
  State<PasswordListPage> createState() => _PasswordListPageState();
}

class _PasswordListPageState extends State<PasswordListPage> {
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
    setState(() { _isLoading = true; });
    final useCase = GetAllPasswordEntries(FirebasePasswordRepositoryImpl());
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
                              trailing: entry.urls.isNotEmpty
                                  ? Icon(Icons.link)
                                  : null,
                              onTap: () {
                                // TODO: Navigate to entry details or edit
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
