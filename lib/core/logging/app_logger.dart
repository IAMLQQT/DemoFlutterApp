import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../error/failure.dart';

/// Single place for error logs. Hook Crashlytics / Sentry in here later.
abstract final class AppLogger {
  static void error(Object error, [StackTrace? stackTrace, String context = 'app']) {
    final String text = error is Failure ? error.debugDescription : '$error';
    developer.log(text, name: context, error: error, stackTrace: stackTrace, level: 1000);
    if (kDebugMode) debugPrint('[$context] $text');
  }

  static void failure(Failure failure, {String context = 'api'}) {
    // Cancelled requests are expected, not errors
    if (failure is CancelledFailure) return;
    error(failure, failure.stackTrace, context);
  }
}
