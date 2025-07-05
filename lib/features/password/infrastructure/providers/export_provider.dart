import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/password/domain/repositories/export_repository.dart';
import 'package:open_password_manager/features/password/infrastructure/repositories/export_repository_impl.dart';

final exportRepositoryProvider = Provider<ExportRepository>(
  (ref) => ExportRepositoryImpl(),
);
