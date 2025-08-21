import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedFolderProvider = NotifierProvider<SelectedFolderState, String?>(
  SelectedFolderState.new,
);

class SelectedFolderState extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void setState(String newFolder) {
    state = newFolder;
  }
}
