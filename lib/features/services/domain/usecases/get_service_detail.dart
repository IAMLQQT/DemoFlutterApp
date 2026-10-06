import '../entities/service_detail.dart'; 
import '../repositories/service_repository.dart';

class GetServiceDetail {
  const GetServiceDetail(this._repository);

  final ServiceRepository _repository;

  Future<ServiceDetail> call(String id) => _repository.getServiceDetail(id);
}