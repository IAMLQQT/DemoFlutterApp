import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_data_source.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl(this._dataSource);
  final ServiceDataSource _dataSource;

  // A detail bloc is created per page, so the cache lives here to make the second visit instant
  final Map<String, ServiceDetail> _detailCache = {};

  @override
  Future<List<ServiceCategory>> getServiceCategories() => _guard(() async {
        final models = await _dataSource.fetchServiceCategories();
        return models.map((m) => m.toEntity()).toList();
      });

  @override
  Future<ServiceDetail> getServiceDetail(String id) async {
    final ServiceDetail? cached = _detailCache[id];
    if (cached != null) return cached;

    final ServiceDetail detail = await _guard(() async {
      final model = await _dataSource.fetchServiceDetail(id);
      return model.toEntity();
    });
    return _detailCache[id] = detail;
  }

  /// Every exception leaving the data layer becomes a logged [Failure].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      final Failure failure = mapToFailure(error, stackTrace);
      AppLogger.failure(failure, context: 'ServiceRepository');
      throw failure;
    }
  }
}
