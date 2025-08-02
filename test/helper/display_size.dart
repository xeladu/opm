import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class DisplaySizes {
  static const Map<String, Size> sizes = {
    'mobile': Size(375, 667), // iPhone size
    'desktop': Size(1920, 1080), // Full HD desktop
  };
}

class DisplaySizeHelper {
  static Future<void> setSize(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size;
  }

  static Future<void> resetSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
  }

  static bool isMobile(Size size) {
    return size.width <= DisplaySizes.sizes.entries.first.value.width &&
        size.height <= DisplaySizes.sizes.entries.first.value.height;
  }
}
