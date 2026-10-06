import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/entities/service_item.dart';

/// One request returns every category with its services; switching tabs never refetches.
final serviceCategoriesProvider = FutureProvider<List<ServiceCategory>>((ref) {
  return ref.watch(getServiceCategoriesProvider)();
});

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null; // null = fall back to the first category

  void select(String categoryId) => state = categoryId;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

/// The tab to highlight: the user's pick, or the first category once loaded.
final activeCategoryIdProvider = Provider<String?>((ref) {
  final String? picked = ref.watch(selectedCategoryProvider);
  return picked ?? ref.watch(serviceCategoriesProvider).value?.firstOrNull?.id;
});

final servicesProvider = Provider<AsyncValue<List<ServiceItem>>>((ref) {
  final String? activeId = ref.watch(activeCategoryIdProvider);
  return ref
      .watch(serviceCategoriesProvider)
      .whenData(
        (categories) =>
            categories.where((c) => c.id == activeId).firstOrNull?.services ??
            const [],
      );
});

/// List data for one service, used to paint the detail header before its content arrives.
final serviceSummaryProvider = Provider.family<ServiceItem?, String>((ref, id) {
  final categories = ref.watch(serviceCategoriesProvider).value ?? const [];
  for (final category in categories) {
    for (final service in category.services) {
      if (service.id == id) return service;
    }
  }
  return null;
});

/// Not autoDispose: an opened article stays cached, so the second visit is instant.
final serviceDetailProvider = FutureProvider.family<ServiceDetail, String>((
  ref,
  id,
) {
  return ref.watch(getServiceDetailProvider)(id);
});
