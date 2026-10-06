import '../entities/service_category.dart';
import '../entities/service_detail.dart';

abstract interface class ServiceRepository {
  Future<List<ServiceCategory>> getServiceCategories();
  Future<ServiceDetail> getServiceDetail(String id);
}
