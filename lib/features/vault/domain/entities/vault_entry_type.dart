import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum VaultEntryType { note, credential, card, ssh, api, oauth, wifi, pgp, smime }

extension VaultEntryTypeExtension on VaultEntryType {
  String toNiceString() {
    switch (this) {
      case VaultEntryType.note:
        return "Note";
      case VaultEntryType.credential:
        return "Credentials";
      case VaultEntryType.card:
        return "Banking/Credit Card";
      case VaultEntryType.ssh:
        return "SSH keys";
      case VaultEntryType.api:
        return "API key";
      case VaultEntryType.oauth:
        return "OAuth";
      case VaultEntryType.wifi:
        return "Wifi";
      case VaultEntryType.pgp:
        return "PGP";
      case VaultEntryType.smime:
        return "S-MIME";
    }
  }

  IconData toIcon() {
    switch (this) {
      case VaultEntryType.note:
        return LucideIcons.stickyNote;
      case VaultEntryType.credential:
        return LucideIcons.keyRound;
      case VaultEntryType.card:
        return LucideIcons.creditCard;
      case VaultEntryType.ssh:
        return LucideIcons.laptop;
      case VaultEntryType.api:
        return LucideIcons.keyRound;
      case VaultEntryType.oauth:
        return LucideIcons.keyRound;
      case VaultEntryType.wifi:
        return LucideIcons.wifi;
      case VaultEntryType.pgp:
        return LucideIcons.messageSquareLock;
      case VaultEntryType.smime:
        return LucideIcons.messageSquareLock;
    }
  }
}
