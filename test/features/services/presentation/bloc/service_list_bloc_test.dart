import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/error/failure.dart';
import 'package:test_app/features/services/data/repositories/service_repository_impl.dart';
import 'package:test_app/features/services/domain/usecases/get_service_categories.dart';
import 'package:test_app/features/services/presentation/bloc/service_list/service_list_bloc.dart';

import '../../../../helpers/fake_service_data_source.dart';

void main() {
  late FakeServiceDataSource dataSource;

  ServiceListBloc buildBloc() =>
      ServiceListBloc(GetServiceCategories(ServiceRepositoryImpl(dataSource)));

  setUp(() => dataSource = FakeServiceDataSource());

  blocTest<ServiceListBloc, ServiceListState>(
    'loads categories and selects the first one',
    build: buildBloc,
    act: (bloc) => bloc.add(const ServiceListStarted()),
    expect: () => [
      isA<ServiceListLoading>(),
      isA<ServiceListLoaded>()
          .having((s) => s.activeCategoryId, 'activeCategoryId', 'hot-id')
          .having((s) => s.services.map((e) => e.id), 'services', ['a', 'b']),
    ],
  );

  blocTest<ServiceListBloc, ServiceListState>(
    'switching category filters in memory without another request',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const ServiceListStarted());
      await bloc.stream.firstWhere((s) => s is ServiceListLoaded);
      bloc.add(const ServiceCategorySelected('skin-id'));
    },
    skip: 2, // Loading + first Loaded
    expect: () => [
      isA<ServiceListLoaded>()
          .having((s) => s.activeCategoryId, 'activeCategoryId', 'skin-id')
          .having((s) => s.services.map((e) => e.id), 'services', ['c']),
    ],
    verify: (_) => expect(dataSource.categoriesCalls, 1),
  );

  blocTest<ServiceListBloc, ServiceListState>(
    'refresh keeps the selected tab and shows no spinner',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const ServiceListStarted());
      await bloc.stream.firstWhere((s) => s is ServiceListLoaded);
      bloc
        ..add(const ServiceCategorySelected('skin-id'))
        ..add(const ServiceListRefreshed());
    },
    skip: 3, // Loading + Loaded + selected
    expect: () => [
      isA<ServiceListLoaded>().having((s) => s.activeCategoryId, 'activeCategoryId', 'skin-id'),
    ],
    verify: (_) => expect(dataSource.categoriesCalls, 2),
  );

  blocTest<ServiceListBloc, ServiceListState>(
    'emits failure with the domain message',
    build: () {
      dataSource = FakeServiceDataSource(error: const NetworkFailure());
      return buildBloc();
    },
    act: (bloc) => bloc.add(const ServiceListStarted()),
    expect: () => [
      isA<ServiceListLoading>(),
      isA<ServiceListFailure>().having((s) => s.message, 'message', 'Không có kết nối mạng'),
    ],
  );

  test('findService returns list data for the detail header', () async {
    final bloc = buildBloc()..add(const ServiceListStarted());
    final state = await bloc.stream.firstWhere((s) => s is ServiceListLoaded) as ServiceListLoaded;

    expect(state.findService('c')?.title, 'Title c');
    expect(state.findService('missing'), isNull);
    await bloc.close();
  });
}
