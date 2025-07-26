import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/password/application/providers/password_filter_query_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PasswordSearchField extends ConsumerStatefulWidget {
  const PasswordSearchField({super.key});

  @override
  ConsumerState<PasswordSearchField> createState() =>
      _PasswordSearchFieldState();
}

class _PasswordSearchFieldState extends ConsumerState<PasswordSearchField> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      ref
          .read(passwordFilterQueryProvider.notifier)
          .setQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clearIcon = _searchController.text.isEmpty
        ? null
        : InkWell(
            hoverColor: Colors.transparent,
            mouseCursor: SystemMouseCursors.click,
            onTap: () {
              _searchController.clear();
            },
            child: Icon(LucideIcons.x),
          );

    return ShadInput(
      controller: _searchController,
      placeholder: const Text('Search all entries'),
      leading: Icon(LucideIcons.search),
      trailing: clearIcon,
    );
  }
}
