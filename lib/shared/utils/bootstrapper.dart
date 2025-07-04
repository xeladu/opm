import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/appwrite_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/firebase_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/supabase_auth_repository_impl.dart';
import 'package:open_password_manager/shared/utils/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Bootstrapper {
  Future<AppConfig> loadConfig() async {
    final configString = await rootBundle.loadString('config.json');
    final configJson = json.decode(configString);
    return AppConfig.fromJson(configJson);
  }

  Future<dynamic> initBackendFromConfig(AppConfig config) async {
    switch (config.provider) {
      case "firebase":
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: config.firebaseConfig.apiKey,
            appId: config.firebaseConfig.appId,
            messagingSenderId: config.firebaseConfig.messagingSenderId,
            projectId: config.firebaseConfig.projectId,
            authDomain: config.firebaseConfig.authDomain,
            measurementId: config.firebaseConfig.measurementId,
            storageBucket: config.firebaseConfig.storageBucket,
          ),
        );
        break;
      case "supabase":
        await Supabase.initialize(
          url: config.supabaseConfig.url,
          anonKey: config.supabaseConfig.anonKey,
        );
        break;
      case "appwrite":
        final appwriteClient = Client();
        appwriteClient.setEndpoint(config.appwriteConfig.endpoint);
        appwriteClient.setProject(config.appwriteConfig.project);
        return appwriteClient;
      default:
        throw Exception("Invalid app configuration");
    }
  }

  AuthRepository getAuthProvider(AppConfig config, Client? client) {
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
}
