class AppConfig {
  final String provider;
  final FirebaseConfig firebaseConfig;
  final SupabaseConfig supabaseConfig;
  final AppwriteConfig appwriteConfig;

  AppConfig({
    required this.provider,
    required this.firebaseConfig,
    required this.supabaseConfig,
    required this.appwriteConfig,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      provider: json['provider'] as String,
      firebaseConfig: FirebaseConfig.fromJson(json["firebaseConfig"]),
      appwriteConfig: AppwriteConfig.fromJson(json["appwriteConfig"]),
      supabaseConfig: SupabaseConfig.fromJson(json["supabaseConfig"]),
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

  FirebaseConfig({
    required this.apiKey,
    required this.authDomain,
    required this.projectId,
    required this.storageBucket,
    required this.messagingSenderId,
    required this.appId,
    required this.measurementId,
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
    );
  }
}

class AppwriteConfig {
  final String endpoint;
  final String project;

  AppwriteConfig({required this.endpoint, required this.project});

  factory AppwriteConfig.fromJson(Map<String, dynamic> json) {
    return AppwriteConfig(
      endpoint: json['endpoint'] as String,
      project: json['project'] as String,
    );
  }
}

class SupabaseConfig {
  final String url;
  final String anonKey;

  SupabaseConfig({required this.url, required this.anonKey});

  factory SupabaseConfig.fromJson(Map<String, dynamic> json) {
    return SupabaseConfig(
      url: json['url'] as String,
      anonKey: json['anonKey'] as String,
    );
  }
}
