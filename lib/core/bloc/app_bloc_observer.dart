import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logging/app_logger.dart';

/// Logs every uncaught error thrown inside a bloc, and state changes in debug builds.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.error(error, stackTrace, bloc.runtimeType.toString());
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType}: ${transition.event.runtimeType} → '
          '${transition.nextState.runtimeType}');
    }
  }
}
