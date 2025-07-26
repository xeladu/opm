import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/shared/application/providers/app_settings_provider.dart';
import 'package:open_password_manager/shared/application/providers/opm_user_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ResponsiveAppFrame extends ConsumerStatefulWidget {
  final String? title;
  final Widget? content;
  final Widget? mobileButton;
  final Widget? desktopButton;
  final Widget? mobileContent;
  final Widget? desktopContent;

  const ResponsiveAppFrame({
    super.key,
    this.mobileContent,
    this.desktopContent,
    this.desktopButton,
    this.mobileButton,
    this.content,
    this.title,
  }) : assert(
         (content != null && mobileContent == null && desktopContent == null) ||
             (content == null &&
                 mobileContent != null &&
                 desktopContent != null),
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

          WidgetsBinding.instance.addPostFrameCallback((_) {
            final settings = ref.read(appSettingsProvider);
            ref
                .read(appSettingsProvider.notifier)
                .setSettings(settings.copyWith(isMobile: isMobile));
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: widget.title != null ? Text(widget.title!) : null,
            actions: [
              ShadAvatar(
                "https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4",
                placeholder: Text(
                  ref.watch(opmUserProvider).user.substring(0, 2),
                ),
              ),
            ],
          ),
          body:
              widget.content ??
              (isMobile ? widget.mobileContent : widget.desktopContent),
          floatingActionButton: (isMobile
              ? widget.mobileButton
              : widget.desktopButton),
        );
      },
    );
  }
}
