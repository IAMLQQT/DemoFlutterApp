import '../entities/service_category.dart';
import '../repositories/service_repository.dart';

class GetServiceCategories {
  const GetServiceCategories(this._repository);

  final ServiceRepository _repository;

  Future<List<ServiceCategory>> call() => _repository.getServiceCategories();
}