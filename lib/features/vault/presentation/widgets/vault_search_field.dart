import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/filter_query_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VaultSearchField extends ConsumerStatefulWidget {
  const VaultSearchField({super.key});

  @override
  ConsumerState<VaultSearchField> createState() => _State();
}

class _State extends ConsumerState<VaultSearchField> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      ref.read(filterQueryProvider.notifier).setQuery(_searchController.text);
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = ref.read(filterQueryProvider);
      setState(() {});
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
      placeholder: const Text('Search your vault'),
      leading: Icon(LucideIcons.search),
      trailing: clearIcon,
    );
  }
}
