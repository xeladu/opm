import 'dart:convert';
import 'dart:io';

/// Generates a `config.json` for a Firebase backend.
///
/// Usage:
///   dart run scripts/generate_config.dart [output_path]
///
/// In CI (GitHub Actions) make sure the following secrets are passed as env vars:
/// - FIREBASE_API_KEY
/// - FIREBASE_AUTH_DOMAIN
/// - FIREBASE_PROJECT_ID
/// - FIREBASE_STORAGE_BUCKET
/// - FIREBASE_MESSAGING_SENDER_ID
/// - FIREBASE_APP_ID
/// - FIREBASE_MEASUREMENT_ID
/// - FIREBASE_VAULT_COLLECTION_PREFIX
/// - FIREBASE_UTILS_COLLECTION_NAME
///
/// The script inserts placeholder values when env vars are not present so the
/// pipeline can still run (and the placeholders can be replaced in downstream steps).

void main(List<String> args) async {
  final outPath = args.isNotEmpty ? args[0] : 'config.json';

  final env = Platform.environment;

  // Read from environment (GitHub Actions should map secrets to these env vars).
  // If a variable is missing, we insert a clear placeholder so it's obvious.
  String envOrPlaceholder(String name) => env[name] ?? '<<${name}_PLACEHOLDER>>';

  final firebaseConfig = {
    'apiKey': envOrPlaceholder('FIREBASE_API_KEY'),
    'authDomain': envOrPlaceholder('FIREBASE_AUTH_DOMAIN'),
    'projectId': envOrPlaceholder('FIREBASE_PROJECT_ID'),
    'storageBucket': envOrPlaceholder('FIREBASE_STORAGE_BUCKET'),
    'messagingSenderId': envOrPlaceholder('FIREBASE_MESSAGING_SENDER_ID'),
    'appId': envOrPlaceholder('FIREBASE_APP_ID'),
    'measurementId': envOrPlaceholder('FIREBASE_MEASUREMENT_ID'),
    'vaultCollectionPrefix': envOrPlaceholder('FIREBASE_VAULT_COLLECTION_PREFIX'),
    'utilsCollectionName': envOrPlaceholder('FIREBASE_UTILS_COLLECTION_NAME'),
  };

  final config = {'provider': 'Firebase', 'firebaseConfig': firebaseConfig};

  final encoder = JsonEncoder.withIndent('  ');
  final jsonContent = encoder.convert(config);

  final file = File(outPath);
  try {
    await file.writeAsString('$jsonContent\n');
    stdout.writeln('Wrote config to: ${file.path}');
  } catch (e) {
    stderr.writeln('Failed to write config file: $e');
    exit(2);
  }
}
