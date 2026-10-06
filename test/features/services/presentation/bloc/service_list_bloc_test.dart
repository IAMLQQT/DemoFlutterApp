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
      isA<ServiceListFailure>().having((s) => s.failure, 'failure', isA<NetworkFailure>()),
    ],
  );

  test('findService returns list data for the detail header', () async {
    final bloc = buildBloc()..add(const ServiceListStarted());
    final state = await bloc.stream.firstWhere((s) => s is ServiceListLoaded) as ServiceListLoaded;

    expect(state.findService('c')?.title, 'Title c');
    expect(state.findService('missing'), isNull);
    await bloc.close();
  });

  blocTest<ServiceListBloc, ServiceListState>(
    'a failed refresh keeps the list and reports the failure once',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const ServiceListStarted());
      await bloc.stream.firstWhere((s) => s is ServiceListLoaded);
      dataSource.error = const NetworkFailure();
      bloc.add(const ServiceListRefreshed());
    },
    skip: 2, // Loading + first Loaded
    expect: () => [
      isA<ServiceListLoaded>()
          .having((s) => s.services.map((e) => e.id), 'services still shown', ['a', 'b'])
          .having((s) => s.refreshFailure, 'refreshFailure', isA<NetworkFailure>()),
    ],
  );

  blocTest<ServiceListBloc, ServiceListState>(
    'the refresh error is cleared by the next user action',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const ServiceListStarted());
      await bloc.stream.firstWhere((s) => s is ServiceListLoaded);
      dataSource.error = const NetworkFailure();
      bloc.add(const ServiceListRefreshed());
      await bloc.stream.firstWhere((s) => s is ServiceListLoaded && s.refreshFailure != null);
      bloc.add(const ServiceCategorySelected('skin-id'));
    },
    skip: 3,
    expect: () => [
      isA<ServiceListLoaded>().having((s) => s.refreshFailure, 'refreshFailure', isNull),
    ],
  );

  blocTest<ServiceListBloc, ServiceListState>(
    'a cancelled refresh changes nothing on screen',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const ServiceListStarted());
      await bloc.stream.firstWhere((s) => s is ServiceListLoaded);
      dataSource.error = const CancelledFailure();
      bloc.add(const ServiceListRefreshed());
    },
    skip: 2,
    expect: () => <ServiceListState>[],
  );

  blocTest<ServiceListBloc, ServiceListState>(
    'retry after a cold-start failure loads the data',
    build: () {
      dataSource = FakeServiceDataSource(error: const TimeoutFailure());
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(const ServiceListStarted());
      await bloc.stream.firstWhere((s) => s is ServiceListFailure);
      dataSource.error = null;
      bloc.add(const ServiceListRefreshed());
    },
    expect: () => [
      isA<ServiceListLoading>(),
      isA<ServiceListFailure>().having((s) => s.failure, 'failure', isA<TimeoutFailure>()),
      isA<ServiceListLoading>(),
      isA<ServiceListLoaded>(),
    ],
  );

  blocTest<ServiceListBloc, ServiceListState>(
    'an empty API response becomes a NotFoundFailure',
    build: () {
      dataSource = FakeServiceDataSource()..returnEmpty = true;
      return buildBloc();
    },
    act: (bloc) => bloc.add(const ServiceListStarted()),
    expect: () => [
      isA<ServiceListLoading>(),
      isA<ServiceListFailure>().having((s) => s.failure, 'failure', isA<NotFoundFailure>()),
    ],
  );
}
