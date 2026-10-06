import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';
import 'core/network/app_client.dart';
import 'core/theme/app_colors.dart';
import 'features/services/di.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _installGlobalErrorHandlers();
  Bloc.observer = const AppBlocObserver();

  // Wrong or missing env file: show what is wrong instead of crashing on start
  final String? configError = ApiConfig.configError;
  if (configError != null) {
    AppLogger.error(StateError(configError), StackTrace.current, 'config');
    runApp(_ConfigErrorApp(message: configError));
    return;
  }

  // Build dependencies once; App hands them to the widget tree
  final serviceRepository = createServiceRepository(createDio());
  runApp(App(serviceRepository: serviceRepository));
}

void _installGlobalErrorHandlers() {
  // Errors thrown while building / laying out / painting widgets
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(details.exception, details.stack, 'flutter');
    if (kDebugMode) FlutterError.presentError(details); // keep the red screen while developing
  };

  // Uncaught async errors (futures, streams, platform callbacks)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.error(error, stack, 'platform');
    return true; // handled: do not crash the app
  };

  // Release builds: a broken widget shows a calm box instead of a grey area
  if (kReleaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) => const ColoredBox(
          color: AppColors.background,
          child: Center(child: Text('Không hiển thị được nội dung này')),
        );
  }
}

class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Cấu hình ứng dụng chưa đúng\n\n$message\n\n'
              'Chạy lại với: --dart-define-from-file=env/dev.json',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
