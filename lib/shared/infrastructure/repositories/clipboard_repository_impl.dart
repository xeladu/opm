import 'package:flutter/services.dart';
import 'package:open_password_manager/shared/domain/repositories/clipboard_repository.dart';

class ClipboardRepositoryImpl implements ClipboardRepository {
  static ClipboardRepositoryImpl? _instance;
  static ClipboardRepositoryImpl get instance {
    _instance ??= ClipboardRepositoryImpl._();

    return _instance!;
  }

  ClipboardRepositoryImpl._();

  @override
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
