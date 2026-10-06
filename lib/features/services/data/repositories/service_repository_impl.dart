import 'package:dio/dio.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_data_source.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  const ServiceRepositoryImpl(this._dataSource);
  final ServiceDataSource _dataSource;

  @override
  Future<List<ServiceCategory>> getServiceCategories() => _guard(() async {
    final models = await _dataSource.fetchServiceCategories();
    return models.map((m) => m.toEntity()).toList();
  });

  @override
  Future<ServiceDetail> getServiceDetail(String id) => _guard(() async {
    final model = await _dataSource.fetchServiceDetail(id);
    return model.toEntity();
  });

  // Translate data-layer exceptions into domain failures
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on Failure {
      rethrow;
    } on ApiException catch (e) {
      throw e.status == 404
          ? NotFoundFailure(e.message)
          : ServerFailure(e.message);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const UnauthorizedFailure();
      throw switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError => const NetworkFailure(),
        DioExceptionType.badResponse => const ServerFailure(),
        _ => UnexpectedFailure(e.message ?? 'Đã có lỗi xảy ra'),
      };
    } on FormatException {
      throw const UnexpectedFailure('Dữ liệu trả về không hợp lệ');
    } on TypeError {
      throw const UnexpectedFailure('Dữ liệu trả về không hợp lệ');
    }
  }
}
