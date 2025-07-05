import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/appwrite_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/firebase_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/supabase_auth_repository_impl.dart';
import 'package:open_password_manager/features/password/domain/repositories/export_repository.dart';
import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';
import 'package:open_password_manager/features/password/infrastructure/repositories/appwrite/appwrite_password_repository_impl.dart';
import 'package:open_password_manager/features/password/infrastructure/repositories/export_repository_impl.dart';
import 'package:open_password_manager/features/password/infrastructure/repositories/firebase/firebase_password_repository_impl.dart';
import 'package:open_password_manager/features/password/infrastructure/repositories/supabase/supabase_password_repository_impl.dart';
import 'package:open_password_manager/shared/utils/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Bootstrapper {
  Future<AppConfig> loadConfig() async {
    final configString = await rootBundle.loadString('config.json');
    final configJson = json.decode(configString);
    return AppConfig.fromJson(configJson);
  }

  Future<dynamic> initBackendFromConfig(AppConfig config) async {
    try {
      switch (config.provider) {
        case "firebase":
          await Firebase.initializeApp(
            options: FirebaseOptions(
              apiKey: config.firebaseConfig!.apiKey,
              appId: config.firebaseConfig!.appId,
              messagingSenderId: config.firebaseConfig!.messagingSenderId,
              projectId: config.firebaseConfig!.projectId,
              authDomain: config.firebaseConfig!.authDomain,
              measurementId: config.firebaseConfig!.measurementId,
              storageBucket: config.firebaseConfig!.storageBucket,
            ),
          );
          break;
        case "supabase":
          await Supabase.initialize(
            url: config.supabaseConfig!.url,
            anonKey: config.supabaseConfig!.anonKey,
          );
          final supabaseClient = SupabaseClient(
            config.supabaseConfig!.url,
            config.supabaseConfig!.anonKey,
          );
          return supabaseClient;
        case "appwrite":
          final appwriteClient = Client();
          appwriteClient.setEndpoint(config.appwriteConfig!.endpoint);
          appwriteClient.setProject(config.appwriteConfig!.projectId);
          return appwriteClient;
        default:
          throw Exception("Invalid app configuration");
      }
    } on Exception catch (ex) {
      throw Exception("Invalid configuration file\r\n${ex.toString()}");
    }
  }

  AuthRepository getAuthProvider(AppConfig config, dynamic client) {
    switch (config.provider) {
      case "firebase":
        return FirebaseAuthRepositoryImpl();
      case "supabase":
        return SupabaseAuthRepositoryImpl();
      case "appwrite":
        return AppwriteAuthRepositoryImpl(client!);
      default:
        throw Exception("Invalid app configuration");
    }
  }

  ExportRepository getExportProvider() {
    return ExportRepositoryImpl();
  }

  PasswordRepository getPasswordProvider(AppConfig config, dynamic client) {
    switch (config.provider) {
      case "firebase":
        return FirebasePasswordRepositoryImpl(config: config.firebaseConfig!);
      case "supabase":
        return SupabasePasswordRepositoryImpl(
          client: client as SupabaseClient,
          databaseName: config.supabaseConfig!.databaseName,
        );
      case "appwrite":
        return AppwritePasswordRepositoryImpl(
          client: client as Client,
          config: config.appwriteConfig!,
        );
      default:
        throw Exception("Invalid app configuration");
    }
  }
}
