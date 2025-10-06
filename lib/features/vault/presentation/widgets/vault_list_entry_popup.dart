import 'package:flutter/material.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VaultListEntryPopup extends StatelessWidget {
  final Function(PopupSelection, VaultEntry) onSelected;
  final VaultEntry entry;

  const VaultListEntryPopup({super.key, required this.onSelected, required this.entry});

  @override
  Widget build(BuildContext context) {
    return ShadTooltip(
      builder: (context) => Text("Show menu"),
      child: PopupMenuButton<PopupSelection>(
        tooltip: "",
        icon: Icon(LucideIcons.ellipsis),
        shape: RoundedRectangleBorder(
          borderRadius: ShadTheme.of(context).radius,
          side: BorderSide(color: ShadTheme.of(context).colorScheme.border, width: 1),
        ),
        color: ShadTheme.of(context).cardTheme.backgroundColor,
        onSelected: (selection) => onSelected(selection, entry),
        itemBuilder: (_) => VaultListEntryPopupItemsBuilder(type: entry.type).build(),
      ),
    );
  }
}

class VaultListEntryPopupItemsBuilder {
  final String type;

  VaultListEntryPopupItemsBuilder({required this.type});

  List<PopupMenuEntry<PopupSelection>> build() {
    final result = <PopupMenuEntry<PopupSelection>>[];
    final convertedType = VaultEntryType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => VaultEntryType.note,
    );

    bool needsDivider = true;

    // TODO only show entry when value is not empty

    switch (convertedType) {
      case VaultEntryType.note:
        needsDivider = false;
        break;
      case VaultEntryType.credential:
        result.add(itemCopyUser);
        result.add(itemCopyPassword);
        result.add(itemOpenUrl);
        break;
      case VaultEntryType.card:
        result.add(itemCopyCardIssuer);
        result.add(itemCopyCardHolderName);
        result.add(itemCopyCardNumber);
        result.add(itemCopyCardExpirationMonth);
        result.add(itemCopyCardExpirationYear);
        result.add(itemCopyCardSecurityCode);
        result.add(itemCopyCardPin);
        break;
      case VaultEntryType.ssh:
        result.add(itemCopySshPrivateKey);
        result.add(itemCopySshPublicKey);
        result.add(itemCopySshFingerprint);
        break;
      case VaultEntryType.api:
        result.add(itemCopyApiKey);
        break;
      case VaultEntryType.oauth:
        result.add(itemCopyOauthAccessToken);
        result.add(itemCopyOauthRefreshToken);
        result.add(itemCopyOauthClientId);
        result.add(itemCopyOauthProvider);
        break;
      case VaultEntryType.wifi:
        result.add(itemCopyWifiPassword);
        result.add(itemCopyWifiSsid);
        break;
      case VaultEntryType.pgp:
        result.add(itemCopyPgpPublicKey);
        result.add(itemCopyPgpPrivateKey);
        result.add(itemCopyPgpFingerprint);
        break;
      case VaultEntryType.smime:
        result.add(itemCopySmimeCertificate);
        result.add(itemCopySmimePrivateKey);
        break;
    }

    if (needsDivider) {
      result.add(PopupMenuDivider());
    }

    result.add(itemView);
    result.add(itemEdit);
    result.add(itemDelete);
    return result;
  }

  PopupMenuItem<PopupSelection> get itemCopyWifiPassword => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyWifiPassword,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy password'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyPgpPrivateKey => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyPgpPrivateKey,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy private key'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyPgpPublicKey => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyPgpPublicKey,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy public key'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyPgpFingerprint => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyPgpFingerprint,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy fingerprint'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopySmimePrivateKey => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copySmimePrivateKey,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy private key'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopySmimeCertificate => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copySmimeCertificate,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy certificate'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopySshPrivateKey => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copySshPrivateKey,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy private key'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopySshPublicKey => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copySshPublicKey,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy public key'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopySshFingerprint => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copySshFingerprint,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy fingerprint'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyWifiSsid => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyWifiSsid,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy SSID'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyApiKey => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyApiKey,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy api key'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyOauthAccessToken => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyOauthAccessToken,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy access token'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyOauthRefreshToken =>
      const PopupMenuItem<PopupSelection>(
        height: sizeL,
        value: PopupSelection.copyOauthRefreshToken,
        child: Row(
          spacing: sizeXS,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.copy, size: sizeS),
            Text('Copy refresh token'),
          ],
        ),
      );
  PopupMenuItem<PopupSelection> get itemCopyOauthClientId => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyOauthClientId,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy client id'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyOauthProvider => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyOauthProvider,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy provider'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyCardIssuer => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyCardIssuer,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy issuer'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyCardHolderName => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyCardHolderName,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy holder name'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyCardNumber => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyCardNumber,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy number'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyCardExpirationYear =>
      const PopupMenuItem<PopupSelection>(
        height: sizeL,
        value: PopupSelection.copyCardExpirationYear,
        child: Row(
          spacing: sizeXS,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.copy, size: sizeS),
            Text('Copy expiration year'),
          ],
        ),
      );
  PopupMenuItem<PopupSelection> get itemCopyCardExpirationMonth =>
      const PopupMenuItem<PopupSelection>(
        height: sizeL,
        value: PopupSelection.copyCardExpirationMonth,
        child: Row(
          spacing: sizeXS,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.copy, size: sizeS),
            Text('Copy expiration month'),
          ],
        ),
      );
  PopupMenuItem<PopupSelection> get itemCopyCardSecurityCode => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyCardSecurityCode,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy security code'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyCardPin => const PopupMenuItem<PopupSelection>(
    height: sizeL,
    value: PopupSelection.copyCardPin,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy PIN'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyUser => const PopupMenuItem(
    height: sizeL,
    value: PopupSelection.copyUser,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy username'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemCopyPassword => const PopupMenuItem(
    height: sizeL,
    value: PopupSelection.copyPassword,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.copy, size: sizeS),
        Text('Copy password'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemOpenUrl => const PopupMenuItem(
    height: sizeL,
    value: PopupSelection.openUrl,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.externalLink, size: sizeS),
        Text('Open URL'),
      ],
    ),
  );

  PopupMenuItem<PopupSelection> get itemView => const PopupMenuItem(
    height: sizeL,
    value: PopupSelection.view,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.view, size: sizeS),
        Text('View'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemEdit => const PopupMenuItem(
    height: sizeL,
    value: PopupSelection.edit,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.pen, size: sizeS),
        Text('Edit'),
      ],
    ),
  );
  PopupMenuItem<PopupSelection> get itemDelete => const PopupMenuItem(
    height: sizeL,
    value: PopupSelection.delete,
    child: Row(
      spacing: sizeXS,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.delete, size: sizeS),
        Text('Delete'),
      ],
    ),
  );
}

enum PopupSelection {
  copyApiKey,
  copySshPrivateKey,
  copySshPublicKey,
  copySshFingerprint,
  copyCardHolderName,
  copyCardNumber,
  copyCardExpirationMonth,
  copyCardExpirationYear,
  copyCardSecurityCode,
  copyCardIssuer,
  copyCardPin,
  copyOauthProvider,
  copyOauthClientId,
  copyOauthAccessToken,
  copyOauthRefreshToken,
  copyWifiSsid,
  copyWifiPassword,
  copyPgpPrivateKey,
  copyPgpPublicKey,
  copyPgpFingerprint,
  copySmimeCertificate,
  copySmimePrivateKey,
  copyUser,
  copyPassword,
  openUrl,
  view,
  edit,
  delete,
}
