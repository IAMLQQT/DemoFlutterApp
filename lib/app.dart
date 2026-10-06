import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/services/domain/repositories/service_repository.dart';
import 'features/services/domain/usecases/get_service_categories.dart';
import 'features/services/domain/usecases/get_service_detail.dart';
import 'features/services/presentation/bloc/service_list/service_list_bloc.dart';

class App extends StatelessWidget {
  const App({super.key, required this.serviceRepository});

  final ServiceRepository serviceRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => GetServiceCategories(serviceRepository)),
        RepositoryProvider(create: (_) => GetServiceDetail(serviceRepository)),
      ],
      // Above the router so the list state survives navigation to detail and back
      child: BlocProvider(
        create: (context) => ServiceListBloc(context.read<GetServiceCategories>())
          ..add(const ServiceListStarted()),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Service App',
          theme: AppTheme.light,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
