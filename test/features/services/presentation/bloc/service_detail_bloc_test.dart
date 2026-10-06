import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/error/failure.dart';
import 'package:test_app/features/services/data/repositories/service_repository_impl.dart';
import 'package:test_app/features/services/domain/usecases/get_service_detail.dart';
import 'package:test_app/features/services/presentation/bloc/service_detail/service_detail_bloc.dart';

import '../../../../helpers/fake_service_data_source.dart';

void main() {
  blocTest<ServiceDetailBloc, ServiceDetailState>(
    'loads the article',
    build: () => ServiceDetailBloc(GetServiceDetail(ServiceRepositoryImpl(FakeServiceDataSource()))),
    act: (bloc) => bloc.add(const ServiceDetailRequested('a')),
    expect: () => [
      isA<ServiceDetailLoading>(),
      isA<ServiceDetailLoaded>().having((s) => s.detail.title, 'title', 'Detail a'),
    ],
  );

  blocTest<ServiceDetailBloc, ServiceDetailState>(
    'emits failure when the request fails',
    build: () => ServiceDetailBloc(
      GetServiceDetail(ServiceRepositoryImpl(FakeServiceDataSource(error: const NotFoundFailure()))),
    ),
    act: (bloc) => bloc.add(const ServiceDetailRequested('a')),
    expect: () => [
      isA<ServiceDetailLoading>(),
      isA<ServiceDetailFailure>().having((s) => s.message, 'message', 'Không tìm thấy dữ liệu'),
    ],
  );
}
