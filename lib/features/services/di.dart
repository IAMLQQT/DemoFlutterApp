import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/app_client.dart';
import 'data/datasources/service_data_source.dart';
import 'data/datasources/service_remote_data_source.dart';
import 'data/repositories/service_repository_impl.dart';
import 'domain/repositories/service_repository.dart';
import 'domain/usecases/get_service_categories.dart';
import 'domain/usecases/get_service_detail.dart';

final serviceDataSourceProvider = Provider<ServiceDataSource>(
  (ref) => ServiceRemoteDataSource(ref.watch(dioProvider)),
);

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepositoryImpl(ref.watch(serviceDataSourceProvider)),
);

final getServiceCategoriesProvider = Provider(
  (ref) => GetServiceCategories(ref.watch(serviceRepositoryProvider)),
);
final getServiceDetailProvider = Provider(
  (ref) => GetServiceDetail(ref.watch(serviceRepositoryProvider)),
);
