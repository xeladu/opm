import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/shared/infrastructure/providers/clipboard_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PlainTextFormField extends ConsumerStatefulWidget {
  final String label;
  final IconData? icon;
  final String? value;
  final bool canCopy;
  final bool canToggle;
  final bool readOnly;
  final int maxLines;

  const PlainTextFormField({
    super.key,
    required this.label,
    this.icon,
    this.value,
    this.canCopy = false,
    this.canToggle = false,
    this.readOnly = false,
    this.maxLines = 1,
  });

  const PlainTextFormField.readOnly({
    Key? key,
    required String label,
    IconData? icon,
    required String? value,
    bool canCopy = false,
    bool canToggle = false,
    int maxLines = 1,
  }) : this(
         key: key,
         label: label,
         icon: icon,
         value: value,
         canCopy: canCopy,
         canToggle: canToggle,
         readOnly: true,
         maxLines: maxLines,
       );

  @override
  ConsumerState<PlainTextFormField> createState() => _State();
}

class _State extends ConsumerState<PlainTextFormField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      id: widget.label,
      style: widget.readOnly
          ? ShadTheme.of(context).textTheme.muted
          : ShadTheme.of(context).textTheme.p,
      maxLines: widget.maxLines,
      initialValue: widget.value,
      readOnly: widget.readOnly,
      obscureText: !widget.canToggle ? false : _obscured,
      label: Text(widget.label),
      leading: widget.icon == null
          ? null
          : Padding(
              padding: EdgeInsets.all(sizeXXS),
              child: Icon(widget.icon!),
            ),
      trailing: !widget.canCopy && !widget.canToggle
          ? null
          : Row(
              children: [
                if (widget.canCopy)
                  SizedBox(
                    width: sizeM,
                    height: sizeM,
                    child: GlyphButton.ghost(
                      icon: LucideIcons.copy,
                      onTap: () async {
                        ref
                            .read(clipboardRepositoryProvider)
                            .copyToClipboard(widget.value ?? "");

                        if (context.mounted) {
                          ToastService.show(context, "${widget.label} copied!");
                        }
                      },
                      tooltip: "Copy value",
                    ),
                  ),
                if (widget.canToggle)
                  SizedBox(
                    width: sizeM,
                    height: sizeM,
                    child: GlyphButton.ghost(
                      icon: _obscured ? LucideIcons.eyeOff : LucideIcons.eye,
                      onTap: () {
                        setState(() {
                          _obscured = !_obscured;
                        });
                      },
                      tooltip: "Show/hide value",
                    ),
                  ),
              ],
            ),
    );
  }
}
