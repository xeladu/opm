import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/filter_query_provider.dart';
import 'package:open_password_manager/shared/application/providers/show_search_field_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/sheets/folder_sheet.dart';
import 'package:open_password_manager/shared/presentation/user_menu.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ResponsiveAppFrame extends ConsumerStatefulWidget {
  final String? title;
  final Widget? content;
  final Widget? mobileButton;
  final Widget? desktopButton;
  final Widget? mobileContent;
  final Widget? desktopContent;
  final bool hideSearchButton;
  final bool hideFolderButton;

  const ResponsiveAppFrame({
    super.key,
    this.mobileContent,
    this.desktopContent,
    this.desktopButton,
    this.mobileButton,
    this.content,
    this.title,
    this.hideSearchButton = false,
    this.hideFolderButton = false,
  }) : assert(
         (content != null && mobileContent == null && desktopContent == null) ||
             (content == null && mobileContent != null && desktopContent != null),
         'Either provide content, or both mobileContent and desktopContent.',
       );

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<ResponsiveAppFrame> {
  bool? _lastIsMobile;

  @override
  Widget build(BuildContext context) {
    return ShadResponsiveBuilder(
      builder: (context, breakpoint) {
        final isMobile = breakpoint < ShadTheme.of(context).breakpoints.sm;

        if (_lastIsMobile == null || _lastIsMobile != isMobile) {
          _lastIsMobile = isMobile;
        }

        final actionButtons = [
          if (isMobile && !widget.hideFolderButton)
            Padding(
              padding: EdgeInsets.only(right: sizeXS),
              child: GlyphButton.ghost(
                icon: LucideIcons.folder,
                size: sizeM,
                onTap: () async {
                  await showShadSheet<String>(
                    context: context,
                    side: ShadSheetSide.right,
                    builder: (context) => FolderSheet(),
                  );
                },
              ),
            ),
          if (isMobile && !widget.hideSearchButton)
            Padding(
              padding: EdgeInsets.only(right: sizeXS),
              child: GlyphButton.ghost(
                onTap: () {
                  final searchFieldVisible = ref.read(showSearchFieldProvider);
                  if (searchFieldVisible) {
                    // clear search query before hiding the search field
                    ref.read(filterQueryProvider.notifier).setQuery("");
                  }

                  ref
                      .read(showSearchFieldProvider.notifier)
                      .setState(!ref.read(showSearchFieldProvider));
                },
                icon: LucideIcons.search,
                size: sizeM,
              ),
            ),
          Padding(
            padding: EdgeInsets.only(right: sizeXS),
            child: UserMenu(),
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: widget.title != null ? Text(widget.title!) : null,
            actions: actionButtons,
          ),
          body: widget.content ?? (isMobile ? widget.mobileContent : widget.desktopContent),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: (isMobile ? widget.mobileButton : widget.desktopButton),
        );
      },
    );
  }
}
