import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PopupService {
  static Future<T?> showPopup<T>(
    BuildContext context,
    List<PopupMenuEntry<T>> menuItems,
    Offset? tapPosition,
  ) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = tapPosition ?? Offset.zero;
    
    return await showMenu<T>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: ShadTheme.of(context).radius,
        side: BorderSide(
          color: ShadTheme.of(context).colorScheme.border,
          width: 1,
        ),
      ),
      color: ShadTheme.of(context).cardTheme.backgroundColor,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: menuItems,
    );
  }
}
