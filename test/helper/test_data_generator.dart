import 'dart:math';

import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';

class TestDataGenerator {
  static VaultEntry vaultEntry({
    String? id,
    String? name,
    String? createdAt,
    String? updatedAt,
    String? username,
    String? password,
    List<String>? urls,
    String? comments,
    String? folder,
    String? type,
  }) {
    return VaultEntry.empty().copyWith(
      id: id ?? "1",
      type: type ?? VaultEntryType.note.name,
      name: name ?? "my-name",
      createdAt: createdAt ?? DateTime(2020, 1, 1, 1, 1, 1).toIso8601String(),
      updatedAt: updatedAt ?? DateTime(2021, 1, 1, 1, 1, 1).toIso8601String(),
      username: username ?? "my-user",
      password: password ?? "my-pass",
      urls: urls ?? ["url1", "url2"],
      comments: comments ?? "my-comments",
      folder: folder ?? "my-folder",
    );
  }

  static VaultEntry randomVaultEntry() {
    return VaultEntry.empty().copyWith(
      id: Random().nextInt(1000).toString(),
      type: VaultEntryType.values[Random().nextInt(VaultEntryType.values.length - 1)].name,
      name: "my-name-${Random().nextInt(1000)}",
      createdAt: DateTime(
        2020,
        Random().nextInt(13),
        Random().nextInt(29),
        Random().nextInt(24),
        Random().nextInt(60),
        Random().nextInt(60),
      ).toIso8601String(),
      updatedAt: DateTime(
        2021,
        Random().nextInt(13),
        Random().nextInt(29),
        Random().nextInt(24),
        Random().nextInt(60),
        Random().nextInt(60),
      ).toIso8601String(),
      username: "my-user-${Random().nextInt(1000)}",
      password: "my-pass-${Random().nextInt(1000)}",
      urls: ["url-${Random().nextInt(1000)}", "url-${Random().nextInt(1000)}"],
      comments: "my-comments-${Random().nextInt(1000)}",
      folder: "my-folder-${Random().nextInt(1000)}",
    );
  }
}
