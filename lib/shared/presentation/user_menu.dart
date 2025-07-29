import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/shared/application/providers/opm_user_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UserMenu extends ConsumerStatefulWidget {
  const UserMenu({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<UserMenu> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
      controller: popoverController,
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          popoverController.toggle();
        },
        child: CircleAvatar(
          child: Text(ref.watch(opmUserProvider).user.substring(0, 2)),
        ),
      ),
      popover: (context) {
        return Text("Here");
      },
    );
  }
}
