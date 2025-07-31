import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/selected_entry_provider.dart';
import 'package:open_password_manager/features/vault/application/use_cases/generate_password.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/password_generator_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/sheet.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PasswordGeneratorSheet extends ConsumerStatefulWidget {
  final Function(String) onGeneratePassword;

  const PasswordGeneratorSheet({super.key, required this.onGeneratePassword});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<PasswordGeneratorSheet> {
  TextEditingController controller = TextEditingController();
  double passwordLength = 14.0;
  bool useUppercase = true;
  bool useLowercase = true;
  bool useNumbers = true;
  bool useSpecialChars = true;

  bool get settingsError =>
      [
        useUppercase,
        useLowercase,
        useNumbers,
        useSpecialChars,
      ].where((element) => element).length <
      2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generatePassword();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sheet(
      title: "Password Generator",
      description: "Generate a custom password.",
      primaryButtonCaption: "Copy password",
      onPrimaryButtonPressed: () async {
        if (settingsError) {
          ToastService.showError(context, "Please fix the errors!");
          return false;
        }

        // insert created password
        final selectedEntry = ref.read(selectedEntryProvider);
        if (selectedEntry == null) {
          ToastService.showError(
            context,
            "Cannot insert password, no entry selected",
          );
          return false;
        }

        widget.onGeneratePassword(controller.text);
        return true;
      },
      secondaryButtonCaption: "Cancel",
      content: Material(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: sizeS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: sizeS,
              children: [
                ShadCard(
                  title: Text(
                    "Password settings",
                    style: ShadTheme.of(context).textTheme.h4,
                  ),
                  description: Text("Set password generation parameters."),
                  child: Column(
                    spacing: sizeS,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: sizeXS),
                      Text(
                        "Length (${passwordLength.toStringAsFixed(0)} characters)",
                        style: ShadTheme.of(context).textTheme.small,
                      ),
                      ShadSlider(
                        initialValue: 15,
                        max: 128,
                        min: 4,
                        onChanged: (value) async {
                          passwordLength = value;

                          await _generatePassword();
                        },
                      ),
                      ShadSwitch(
                        value: useUppercase,
                        label: Text("Use uppercase letters (A-Z)"),
                        onChanged: (value) async {
                          useUppercase = value;

                          await _generatePassword();
                        },
                      ),
                      ShadSwitch(
                        value: useLowercase,
                        label: Text("Use lowercase letters (a-z)"),
                        onChanged: (value) async {
                          useLowercase = value;

                          await _generatePassword();
                        },
                      ),
                      ShadSwitch(
                        value: useNumbers,
                        label: Text("Use numbers (0-9)"),
                        onChanged: (value) async {
                          useNumbers = value;

                          await _generatePassword();
                        },
                      ),
                      ShadSwitch(
                        value: useSpecialChars,
                        label: Text("Use special characters (!@#\$%^&*)"),
                        onChanged: (value) async {
                          useSpecialChars = value;

                          await _generatePassword();
                        },
                      ),
                      if (settingsError)
                        Text(
                          "Choose at least two options!",
                          style: ShadTheme.of(
                            context,
                          ).textTheme.small.copyWith(color: Colors.red),
                        ),
                    ],
                  ),
                ),
                ShadInputFormField(
                  controller: controller,
                  readOnly: true,
                  minLines: 1,
                  maxLines: null,
                  label: Text("Generated password"),
                  trailing: SizedBox(
                    width: sizeM,
                    height: sizeM,
                    child: GlyphButton.ghost(
                      icon: LucideIcons.refreshCcw,
                      onTap: () async => _generatePassword(),
                      tooltip: "Create random password",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generatePassword() async {
    if (settingsError) {
      setState(() {
        controller.text = "ERROR";
      });
      return;
    }

    final repo = ref.read(passwordGeneratorRepositoryProvider);
    final useCase = GeneratePassword(repo: repo);

    final result = useCase(
      useUppercase,
      useLowercase,
      useNumbers,
      useSpecialChars,
      passwordLength.toInt(),
    );

    setState(() {
      controller.text = result;
    });
  }
}
