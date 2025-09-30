import 'package:flutter/material.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PasswordFormField extends StatefulWidget {
  final String? placeholder;
  final VoidCallback? onChanged;
  final String? Function(String?)? validator;

  // Tooltips produce errors in widget tests. This property is only to disable them during testing.
  // https://github.com/nank1ro/flutter-shadcn-ui/issues/294
  final bool noTooltip;

  const PasswordFormField({
    super.key,
    this.placeholder,
    this.validator,
    this.onChanged,
    this.noTooltip = false,
  });

  @override
  State<PasswordFormField> createState() => _State();
}

class _State extends State<PasswordFormField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      id: widget.placeholder == null
          ? "password"
          : widget.placeholder!.toLowerCase().replaceAll(" ", "_"),
      placeholder: Text(widget.placeholder ?? 'Password'),
      obscureText: _obscurePassword,
      leading: const Padding(padding: EdgeInsets.all(sizeXXS), child: Icon(LucideIcons.lock)),
      trailing: SizedBox(
        width: sizeM,
        height: sizeM,
        child: GlyphButton.ghost(
          icon: _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
          onTap: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          tooltip: widget.noTooltip ? null : "Show/hide password",
        ),
      ),
      validator: (v) {
        return v.isEmpty
            ? "Please enter a value"
            : widget.validator != null
            ? widget.validator!(v)
            : null;
      },
      onChanged: (_) {
        if (widget.onChanged != null) widget.onChanged!();
      },
    );
  }
}
