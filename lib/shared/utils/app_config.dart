import 'package:open_password_manager/shared/utils/hosting_provider.dart';

class AppConfig {
  final HostingProvider provider;
  final FirebaseConfig? firebaseConfig;
  final SupabaseConfig? supabaseConfig;
  final AppwriteConfig? appwriteConfig;

  AppConfig({
    required this.provider,
    this.firebaseConfig,
    this.supabaseConfig,
    this.appwriteConfig,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      provider: HostingProvider.values.firstWhere(
        (provider) =>
            (json['provider'] as String).toLowerCase() == provider.name,
      ),
      firebaseConfig: json.containsKey("firebaseConfig")
          ? FirebaseConfig.fromJson(json["firebaseConfig"])
          : null,
      appwriteConfig: json.containsKey("appwriteConfig")
          ? AppwriteConfig.fromJson(json["appwriteConfig"])
          : null,
      supabaseConfig: json.containsKey("supabaseConfig")
          ? SupabaseConfig.fromJson(json["supabaseConfig"])
          : null,
    );
  }
}

class FirebaseConfig {
  final String apiKey;
  final String authDomain;
  final String projectId;
  final String storageBucket;
  final String messagingSenderId;
  final String appId;
  final String measurementId;
  final String collectionId;

  FirebaseConfig({
    required this.apiKey,
    required this.authDomain,
    required this.projectId,
    required this.storageBucket,
    required this.messagingSenderId,
    required this.appId,
    required this.measurementId,
    required this.collectionId,
  });

  factory FirebaseConfig.fromJson(Map<String, dynamic> json) {
    return FirebaseConfig(
      apiKey: json['apiKey'] as String,
      authDomain: json['authDomain'] as String,
      projectId: json['projectId'] as String,
      storageBucket: json['storageBucket'] as String,
      messagingSenderId: json['messagingSenderId'] as String,
      appId: json['appId'] as String,
      measurementId: json['measurementId'] as String,
      collectionId: json["collectionId"] as String,
    );
  }
}

class AppwriteConfig {
  final String endpoint;
  final String projectId;
  final String databaseId;
  final String passwordCollectionId;
  final String saltCollectionId;

  AppwriteConfig({
    required this.endpoint,
    required this.projectId,
    required this.databaseId,
    required this.saltCollectionId,
    required this.passwordCollectionId,
  });

  factory AppwriteConfig.fromJson(Map<String, dynamic> json) {
    return AppwriteConfig(
      endpoint: json['endpoint'] as String,
      projectId: json['projectId'] as String,
      databaseId: json["databaseId"] as String,
      passwordCollectionId: json["passwordCollectionId"] as String,
      saltCollectionId: json["saltCollectionId"] as String,
    );
  }
}

class SupabaseConfig {
  final String url;
  final String anonKey;
  final String passwordDbName;
  final String saltDbName;

  SupabaseConfig({
    required this.url,
    required this.anonKey,
    required this.passwordDbName,
    required this.saltDbName,
  });

  factory SupabaseConfig.fromJson(Map<String, dynamic> json) {
    return SupabaseConfig(
      url: json['url'] as String,
      anonKey: json['anonKey'] as String,
      passwordDbName: json["passwordDbName"] as String,
      saltDbName: json["saltDbName"] as String,
    );
  }
}
