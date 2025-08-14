import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_repository_provider.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ThemeModeSetting extends ConsumerWidget {
  const ThemeModeSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: sizeXS,
      children: [
        Text("Choose your theme mode", style: ShadTheme.of(context).textTheme.small),
        ShadSelect<ThemeMode>(
          maxWidth: selectLargeWidth,
          minWidth: selectLargeWidth,
          initialValue: ref.read(settingsProvider).themeMode,
          options: ThemeMode.values.map(
            (item) => ShadOption(value: item, child: Text(_convertName(item))),
          ),
          selectedOptionBuilder: (context, value) => Text(_convertName(value)),
          onChanged: (value) async {
            final settings = ref.read(settingsProvider);
            final newSettings = settings.copyWith(newThemeMode: value);

            ref.read(settingsProvider.notifier).setSettings(newSettings);
            await ref.read(settingsRepositoryProvider).save(newSettings);
          },
        ),
      ],
    );
  }

  String _convertName(ThemeMode mode) {
    final value = "${mode.name.replaceAll("ThemeMode.", "")} mode";
    return value[0].toUpperCase() + value.substring(1);
  }
}
