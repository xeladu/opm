import 'package:flutter/material.dart';
import 'package:open_password_manager/features/vault/domain/entities/card_issuer.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/strength_indicator.dart';
import 'package:open_password_manager/shared/presentation/inputs/plain_text_form_field.dart';
import 'package:open_password_manager/style/ui.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:timeago/timeago.dart' as timeago;

class VaultEntryDetails extends StatelessWidget {
  final VaultEntry entry;

  const VaultEntryDetails({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("yyyy/dd/MM, HH:mm:ss");
    final createdAtDate = DateTime.parse(entry.createdAt);
    final updatedAtDate = DateTime.parse(entry.updatedAt);

    return SingleChildScrollView(
      child: Column(
        children: [
          ShadCard(
            padding: EdgeInsets.all(sizeS),
            child: Column(
              spacing: sizeXS,
              children: [PlainTextFormField.readOnly(label: "Name", value: entry.name)],
            ),
          ),
          const SizedBox(height: sizeXS),
          ShadCard(
            padding: EdgeInsets.all(sizeS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: sizeXS,
              children: [
                // credentials
                if (entry.username.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "Username",
                    value: entry.username,
                    canCopy: true,
                  ),
                if (entry.password.isNotEmpty) ...[
                  PlainTextFormField.readOnly(
                    label: "Password",
                    value: entry.password,
                    canToggle: true,
                    canCopy: true,
                  ),
                  StrengthIndicator(password: entry.password),
                ],
                if (entry.urls.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "URLs",
                    value: entry.urls.join('\n'),
                    maxLines: 3,
                  ),

                // ssh
                if (entry.sshPrivateKey.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "SSH Private Key",
                    value: entry.sshPrivateKey,
                    canToggle: true,
                    canCopy: true,
                  ),
                if (entry.sshPublicKey.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "SSH Public Key",
                    value: entry.sshPublicKey,
                    canCopy: true,
                  ),
                if (entry.sshFingerprint.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "SSH Fingerprint",
                    value: entry.sshFingerprint,
                    canCopy: true,
                  ),

                // api
                if (entry.apiKey.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "API Key",
                    value: entry.apiKey,
                    canToggle: true,
                    canCopy: true,
                  ),

                // pgp
                if (entry.pgpPrivateKey.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "PGP Private Key",
                    value: entry.pgpPrivateKey,
                    canToggle: true,
                    canCopy: true,
                  ),
                if (entry.pgpPublicKey.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "PGP Public Key",
                    value: entry.pgpPublicKey,
                    canCopy: true,
                  ),
                if (entry.pgpFingerprint.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "PGP Fingerprint",
                    value: entry.pgpFingerprint,
                    canCopy: true,
                  ),

                // bank/credit
                if (entry.cardIssuer.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "Card Issuer",
                    value: CardIssuer.values
                        .firstWhere((v) => v.name == entry.cardIssuer)
                        .toNiceString(),
                    canCopy: true,
                  ),
                if (entry.cardHolderName.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "Card Holder Name",
                    value: entry.cardHolderName,
                    canCopy: true,
                  ),
                if (entry.cardNumber.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "Card Number",
                    value: entry.cardNumber,
                    canCopy: true,
                  ),
                if (entry.cardExpirationMonth.isNotEmpty && entry.cardExpirationYear.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "Expiration Date",
                    value: "${entry.cardExpirationMonth} / ${entry.cardExpirationYear}",
                    canCopy: true,
                  ),
                if (entry.cardSecurityCode.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "Card Security Code",
                    value: entry.cardSecurityCode,
                    canCopy: true,
                    canToggle: true,
                  ),
                if (entry.cardPin.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "Card PIN",
                    value: entry.cardPin,
                    canCopy: true,
                    canToggle: true,
                  ),

                // smime
                if (entry.smimeCertificate.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "S-MIME Certificate",
                    value: entry.smimeCertificate,
                    canToggle: true,
                    canCopy: true,
                  ),
                if (entry.smimePrivateKey.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "S-MIME Private Key",
                    value: entry.smimePrivateKey,
                    canToggle: true,
                    canCopy: true,
                  ),

                // wifi
                if (entry.wifiSsid.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "WiFi SSID",
                    value: entry.wifiSsid,
                    canCopy: true,
                  ),
                if (entry.wifiPassword.isNotEmpty) ...[
                  PlainTextFormField.readOnly(
                    label: "WiFi Password",
                    value: entry.wifiPassword,
                    canToggle: true,
                    canCopy: true,
                  ),
                  StrengthIndicator(password: entry.wifiPassword),
                ],

                // oauth
                if (entry.oauthAccessToken.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "OAuth Access Token",
                    value: entry.oauthAccessToken,
                    canToggle: true,
                    canCopy: true,
                  ),
                if (entry.oauthRefreshToken.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "OAuth Refresh Token",
                    value: entry.oauthRefreshToken,
                    canToggle: true,
                    canCopy: true,
                  ),
                if (entry.oauthClientId.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "OAuth Client ID",
                    value: entry.oauthClientId,
                    canCopy: true,
                  ),
                if (entry.oauthProvider.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "OAuth Provider",
                    value: entry.oauthProvider,
                    canCopy: true,
                  ),

                // other fields
                if (entry.comments.isNotEmpty)
                  PlainTextFormField.readOnly(
                    label: "Comments",
                    value: entry.comments,
                    canCopy: true,
                  ),
                PlainTextFormField.readOnly(label: "Folder", value: entry.folder),
              ],
            ),
          ),
          const SizedBox(height: sizeXS),
          ShadCard(
            padding: EdgeInsets.all(sizeS),
            child: Column(
              spacing: sizeXS,
              children: [
                PlainTextFormField.readOnly(
                  label: "Created At",
                  value:
                      "${df.format(createdAtDate)} (${timeago.format(createdAtDate, locale: 'en')})",
                ),
                PlainTextFormField.readOnly(
                  label: "Updated At",
                  value:
                      "${df.format(updatedAtDate)} (${timeago.format(updatedAtDate, locale: 'en')})",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
