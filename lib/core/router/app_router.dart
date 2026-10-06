import 'package:go_router/go_router.dart';

import '../../features/services/presentation/pages/service_detail_page.dart';
import '../../features/services/presentation/pages/service_list_page.dart';

abstract class AppRoutes {
  static const String services ='/services';
  static String serviceDetail(String serviceId) => '/services/$serviceId';
}

final GoRouter appRouter = GoRouter (
  initialLocation: AppRoutes.services,
  routes: [
    GoRoute(
      path: AppRoutes.services,
      builder: (context, state) => const ServiceListPage(),
      routes: [
        GoRoute(
          path: ':serviceId',
          builder: (context, state) => ServiceDetailPage(serviceId: state.pathParameters['serviceId']!),
        )
      ]
    )]
);