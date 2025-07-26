import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/password/application/use_cases/get_all_password_entries.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/infrastructure/providers/password_provider.dart';

/// Returns all password entries from the database
final allPasswordEntriesProvider =
    AsyncNotifierProvider<AllPasswordEntriesState, List<PasswordEntry>>(
      AllPasswordEntriesState.new,
    );

class AllPasswordEntriesState extends AsyncNotifier<List<PasswordEntry>> {
  @override
  FutureOr<List<PasswordEntry>> build() async {
    ref.keepAlive();
    
    final repo = ref.read(passwordRepositoryProvider);
    final useCase = GetAllPasswordEntries(repo);

    return await useCase();
  }
}
