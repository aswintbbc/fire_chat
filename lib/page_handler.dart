import 'package:fire_chat/screens/page1.dart';
import 'package:fire_chat/screens/sample_page.dart';
import 'package:flutter/widgets.dart';

/// Handles the navigation and display logic for different pages based on the URI.
class PageHandler {
  static Widget? page;

  static void handleUri(Uri? uri) {
    if (uri == null || uri.queryParameters.isEmpty) return;

    final String pageFromUri = uri.queryParameters['id'] ?? '';

    if (pageFromUri == 'green') {
      page = SamplePage();
    } else {
      page = Page1(data: uri);
    }
  }
}
