import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/error/failure.dart';
import 'package:test_app/core/network/api_response.dart';
import 'package:test_app/features/services/data/repositories/service_repository_impl.dart';

import '../../../../helpers/fake_service_data_source.dart';

void main() {
  ServiceRepositoryImpl repoThrowing(Object error) =>
      ServiceRepositoryImpl(FakeServiceDataSource(error: error));

  test('maps models to entities', () async {
    final repository = ServiceRepositoryImpl(FakeServiceDataSource());

    final categories = await repository.getServiceCategories();
    final detail = await repository.getServiceDetail('a');

    expect(categories.map((c) => c.id), ['hot-id', 'skin-id', 'care-id']);
    expect(detail.id, 'a');
  });

  test('envelope 404 becomes NotFoundFailure', () {
    expect(
      repoThrowing(const ApiException(status: 404, message: 'x')).getServiceDetail('a'),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('other envelope errors become ServerFailure', () {
    expect(
      repoThrowing(const ApiException(status: 500, message: 'x')).getServiceCategories(),
      throwsA(isA<ServerFailure>()),
    );
  });

  test('HTTP 401 becomes UnauthorizedFailure', () {
    final options = RequestOptions(path: '/news/screen');
    final error = DioException(
      requestOptions: options,
      response: Response<Object>(requestOptions: options, statusCode: 401),
      type: DioExceptionType.badResponse,
    );

    expect(repoThrowing(error).getServiceCategories(), throwsA(isA<UnauthorizedFailure>()));
  });

  test('connection errors become NetworkFailure', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/news/screen'),
      type: DioExceptionType.connectionError,
    );

    expect(repoThrowing(error).getServiceCategories(), throwsA(isA<NetworkFailure>()));
  });

  test('malformed data becomes InvalidDataFailure', () {
    expect(
      repoThrowing(const FormatException('bad')).getServiceCategories(),
      throwsA(isA<InvalidDataFailure>()),
    );
  });

  test('caches a loaded detail so the next visit skips the request', () async {
    final dataSource = FakeServiceDataSource();
    final repository = ServiceRepositoryImpl(dataSource);

    await repository.getServiceDetail('a');
    await repository.getServiceDetail('a');

    expect(dataSource.detailCalls['a'], 1);
  });
}
