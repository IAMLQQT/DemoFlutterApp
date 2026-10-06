import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/features/services/di.dart';
import 'package:test_app/features/services/presentation/providers/service_providers.dart';

import '../../../../helpers/fake_service_data_source.dart';

void main() {
  late FakeServiceDataSource dataSource;
  late ProviderContainer container;

  setUp(() {
    dataSource = FakeServiceDataSource();
    container = ProviderContainer(
      overrides: [serviceDataSourceProvider.overrideWithValue(dataSource)],
    );
    container.listen(servicesProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('selects the first category once loaded', () async {
    await container.read(serviceCategoriesProvider.future);

    expect(container.read(activeCategoryIdProvider), 'hot-id');
    expect(container.read(servicesProvider).value?.map((s) => s.id), ['a', 'b']);
  });

  test('switching categories is instant and uses a single request', () async {
    await container.read(serviceCategoriesProvider.future);

    container.read(selectedCategoryProvider.notifier).select('skin-id');
    final skin = container.read(servicesProvider);
    container.read(selectedCategoryProvider.notifier).select('hot-id');
    final hot = container.read(servicesProvider);

    expect(skin.isLoading, isFalse);
    expect(skin.value?.map((s) => s.id), ['c']);
    expect(hot.value?.map((s) => s.id), ['a', 'b']);
    expect(dataSource.categoriesCalls, 1);
  });

  test('summary is available before the detail request finishes', () async {
    await container.read(serviceCategoriesProvider.future);

    expect(container.read(serviceSummaryProvider('c'))?.title, 'Title c');
    expect(container.read(serviceSummaryProvider('missing')), isNull);
  });

  test('an opened detail is cached for the next visit', () async {
    final sub = container.listen(serviceDetailProvider('a'), (_, _) {});
    await container.read(serviceDetailProvider('a').future);
    sub.close();

    final again = container.read(serviceDetailProvider('a'));

    expect(again.hasValue, isTrue);
    expect(dataSource.detailCalls['a'], 1);
  });
}
