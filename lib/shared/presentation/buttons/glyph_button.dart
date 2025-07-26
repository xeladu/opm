import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GlyphButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  final IconData icon;
  final IconButtonStyle style;
  final String? tooltip;

  const GlyphButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.enabled = true,
    this.tooltip,
    this.style = IconButtonStyle.standard,
  });

  const GlyphButton.ghost({
    Key? key,
    required VoidCallback onTap,
    required IconData icon,
    bool enabled = true,
    String? tooltip,
  }) : this(
         key: key,
         enabled: enabled,
         onTap: onTap,
         icon: icon,
         style: IconButtonStyle.ghost,
         tooltip: tooltip,
       );

  const GlyphButton.important({
    Key? key,
    required VoidCallback onTap,
    required IconData icon,
    bool enabled = true,
    String? tooltip,
  }) : this(
         key: key,
         enabled: enabled,
         onTap: onTap,
         icon: icon,
         style: IconButtonStyle.important,
         tooltip: tooltip,
       );

  @override
  Widget build(BuildContext context) {
    ShadIconButton? button;
    switch (style) {
      case IconButtonStyle.standard:
        button = ShadIconButton.secondary(
          padding: EdgeInsets.zero,
          enabled: enabled,
          icon: Icon(icon),
          onPressed: onTap,
        );
      case IconButtonStyle.ghost:
        button = ShadIconButton.ghost(
          padding: EdgeInsets.zero,
          enabled: enabled,
          icon: Icon(icon),
          onPressed: onTap,
        );
      case IconButtonStyle.important:
        button = ShadIconButton.destructive(
          padding: EdgeInsets.zero,
          enabled: enabled,
          icon: Icon(icon),
          onPressed: onTap,
        );
    }

    return tooltip != null
        ? ShadTooltip(child: button, builder: (context) => Text(tooltip!))
        : button;
  }
}

enum IconButtonStyle { standard, ghost, important }
