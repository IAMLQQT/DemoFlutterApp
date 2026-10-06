import '../models/service_category_model.dart';
import '../models/service_detail_model.dart';

abstract interface class ServiceDataSource {
  Future<List<ServiceCategoryModel>> fetchServiceCategories();
  Future<ServiceDetailModel> fetchServiceDetail(String id);
}
