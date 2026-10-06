import 'package:test_app/features/services/data/datasources/service_data_source.dart';
import 'package:test_app/features/services/data/models/service_category_model.dart';
import 'package:test_app/features/services/data/models/service_detail_model.dart';

import 'service_fixtures.dart';

/// In-memory data source built from the fixtures; counts calls so tests can assert caching.
class FakeServiceDataSource implements ServiceDataSource {
  FakeServiceDataSource({this.error});

  /// When set, every call throws this instead of returning data.
  Object? error;

  /// When true, the categories call succeeds with an empty list.
  bool returnEmpty = false;

  int categoriesCalls = 0;
  final Map<String, int> detailCalls = {};

  @override
  Future<List<ServiceCategoryModel>> fetchServiceCategories() async {
    categoriesCalls++;
    if (error != null) throw error!;
    if (returnEmpty) return [];
    return (screenResponseJson()['data'] as List<dynamic>)
        .map((e) => ServiceCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ServiceDetailModel> fetchServiceDetail(String id) async {
    detailCalls.update(id, (n) => n + 1, ifAbsent: () => 1);
    if (error != null) throw error!;
    return ServiceDetailModel.fromJson(detailJson(id));
  }
}
