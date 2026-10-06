import 'package:dio/dio.dart';

import 'data/datasources/service_data_source.dart';
import 'data/datasources/service_remote_data_source.dart';
import 'data/repositories/service_repository_impl.dart';
import 'domain/repositories/service_repository.dart';

/// Composition root of the feature: the only place that knows the data layer.
ServiceRepository createServiceRepository(Dio dio, {ServiceDataSource? dataSource}) {
  return ServiceRepositoryImpl(dataSource ?? ServiceRemoteDataSource(dio));
}
