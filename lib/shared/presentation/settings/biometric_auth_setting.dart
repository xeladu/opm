import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/application/providers/biometric_auth_available_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_repository_provider.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BiometricAuthSetting extends ConsumerWidget {
  const BiometricAuthSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricAvailable = ref.watch(biometricAuthAvailableProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: sizeXS,
      children: [
        ShadSwitch(
          label: Text("Use biometric authentication"),
          sublabel: Text("Sign in with your fingerprint or face ID"),
          value: ref.watch(settingsProvider).biometricAuthEnabled,
          enabled: biometricAvailable.when(
            data: (value) => value,
            error: (_, _) => false,
            loading: () => false,
          ),
          onChanged: (value) async {
            final settings = ref.read(settingsProvider);
            final newSettings = settings.copyWith(newBiometricAuthEnabled: value);
            ref.read(settingsProvider.notifier).setSettings(newSettings);

            await ref.read(settingsRepositoryProvider).save(newSettings);
          },
        ),
        ShadCard(
          child: Row(
            spacing: sizeXS,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: biometricAvailable.when(
              data: (value) => [
                Icon(
                  LucideIcons.triangleAlert,
                  color: value ? Colors.orange : Colors.red,
                  size: sizeL,
                ),
                Expanded(
                  child: Text(
                    value
                        ? "Biometric authentication can impose security risks because the encryption key is stored on the device!"
                        : "Biometric authentication is not available for this device!",
                  ),
                ),
              ],
              loading: () => [
                Icon(LucideIcons.triangleAlert, color: Colors.red, size: sizeL),
                Expanded(child: Text("Biometric authentication is not available for this device!")),
              ],
              error: (_, _) => [
                Icon(LucideIcons.triangleAlert, color: Colors.red, size: sizeL),
                Expanded(child: Text("Biometric authentication is not available for this device!")),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
