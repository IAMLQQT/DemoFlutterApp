import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Shared HTTP client, created once in main.dart.
Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'key': ApiConfig.appKey, // the API only accepts the header name "key"
        'token': ApiConfig.token,
        'Cookie': 'i18next=${ApiConfig.language}',
      },
    ),
  );

  // Print every request/response in the Debug Console; never runs in release builds
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        responseBody: true,
        logPrint: (Object object) => debugPrint(object.toString()),
      ),
    );
  }

  return dio;
}
