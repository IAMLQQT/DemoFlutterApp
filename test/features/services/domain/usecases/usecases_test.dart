import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/features/services/domain/entities/service_category.dart';
import 'package:test_app/features/services/domain/entities/service_detail.dart';
import 'package:test_app/features/services/domain/repositories/service_repository.dart';
import 'package:test_app/features/services/domain/usecases/get_service_categories.dart';
import 'package:test_app/features/services/domain/usecases/get_service_detail.dart';

class _FakeRepository implements ServiceRepository {
  final List<String> calls = [];

  @override
  Future<List<ServiceCategory>> getServiceCategories() async {
    calls.add('getServiceCategories');
    return const [ServiceCategory(id: 'c', name: 'C', iconUrl: '')];
  }

  @override
  Future<ServiceDetail> getServiceDetail(String id) async {
    calls.add('getServiceDetail:$id');
    return ServiceDetail(
      id: id,
      title: 't',
      bannerUrl: 'b',
      contentHtml: '',
      shareLink: '',
      bookingActions: const [],
    );
  }
}

void main() {
  late _FakeRepository repository;

  setUp(() => repository = _FakeRepository());

  test('GetServiceCategories calls the repository', () async {
    final result = await GetServiceCategories(repository)();

    expect(result.single.id, 'c');
    expect(repository.calls, ['getServiceCategories']);
  });

  test('GetServiceDetail forwards the id', () async {
    final result = await GetServiceDetail(repository)('x');

    expect(result.id, 'x');
    expect(repository.calls, ['getServiceDetail:x']);
  });
}
