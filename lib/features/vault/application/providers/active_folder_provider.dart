import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contains the current folder selected by the user
final activeFolderProvider = NotifierProvider<ActiveFolderState, String>(ActiveFolderState.new);

class ActiveFolderState extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void setFolder(String folder) {
    state = folder;
  }
}
