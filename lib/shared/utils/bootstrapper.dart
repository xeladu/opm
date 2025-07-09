import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_password_manager/shared/utils/app_config.dart';
import 'package:open_password_manager/shared/utils/hosting_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Bootstrapper {
  AppConfig? _appConfig;
  SupabaseClient? _supabaseClient;
  Client? _appwriteClient;
  HostingProvider? _provider;

  SupabaseClient? get supabaseClient => _supabaseClient;

  Client? get appwriteClient => _appwriteClient;

  AppConfig get appConfig {
    if (_appConfig == null) throw Exception("App not initialized");

    return _appConfig!;
  }

  HostingProvider get provider {
    if (_provider == null) throw Exception("App not initialized");

    return _provider!;
  }

  Future<void> initBackendFromConfig() async {
    try {
      _appConfig = await _loadConfig();
      _provider = _appConfig!.provider;

      switch (_provider!) {
        case HostingProvider.firebase:
          await Firebase.initializeApp(
            options: FirebaseOptions(
              apiKey: _appConfig!.firebaseConfig!.apiKey,
              appId: _appConfig!.firebaseConfig!.appId,
              messagingSenderId: _appConfig!.firebaseConfig!.messagingSenderId,
              projectId: _appConfig!.firebaseConfig!.projectId,
              authDomain: _appConfig!.firebaseConfig!.authDomain,
              measurementId: _appConfig!.firebaseConfig!.measurementId,
              storageBucket: _appConfig!.firebaseConfig!.storageBucket,
            ),
          );
          break;
        case HostingProvider.supabase:
          await Supabase.initialize(
            url: _appConfig!.supabaseConfig!.url,
            anonKey: _appConfig!.supabaseConfig!.anonKey,
          );
          _supabaseClient = SupabaseClient(
            _appConfig!.supabaseConfig!.url,
            _appConfig!.supabaseConfig!.anonKey,
          );
        case HostingProvider.appwrite:
          _appwriteClient = Client();
          _appwriteClient!.setEndpoint(_appConfig!.appwriteConfig!.endpoint);
          _appwriteClient!.setProject(_appConfig!.appwriteConfig!.projectId);
      }
    } on Exception catch (ex) {
      throw Exception("Invalid configuration file\r\n${ex.toString()}");
    }
  }

  Future<AppConfig> _loadConfig() async {
    final configString = await rootBundle.loadString('config.json');
    final configJson = json.decode(configString);
    return AppConfig.fromJson(configJson);
  }
}
