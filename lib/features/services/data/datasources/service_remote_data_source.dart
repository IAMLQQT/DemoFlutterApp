import 'package:dio/dio.dart';

import '../../../../core/network/api_response.dart';
import '../models/service_category_model.dart';
import '../models/service_detail_model.dart';
import 'service_data_source.dart';

class ServiceRemoteDataSource implements ServiceDataSource {
  const ServiceRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<ServiceCategoryModel>> fetchServiceCategories() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/news/screen',
      queryParameters: {'group': 'service'},
    );
    return unwrapEnvelope(
      response.data,
      (data) => (data as List<dynamic>)
          .map((e) => ServiceCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<ServiceDetailModel> fetchServiceDetail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/news/content/$id');
    return unwrapEnvelope(
      response.data,
      (data) => ServiceDetailModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
