import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

class LogService {
  static void recordFlutterFatalError(FlutterErrorDetails details) {
    try {
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      unawaited(FirebaseCrashlytics.instance.recordFlutterFatalError(details));
    } catch (e, stack) {
      debugPrint('Flutter fatal error: $details');
      debugPrint('Crashlytics error: $e\n$stack');
    }
  }
}
