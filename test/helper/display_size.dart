import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class DisplaySizes {
  static Map<String, Size> sizes = {
    "mobile": Size(375, 500),
    "desktop": Size(1200, 800),
  };
}

class DisplaySizeHelper {
  static Future<void> setSize(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
  }

  static Future<void> resetSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(null);
  }
}
