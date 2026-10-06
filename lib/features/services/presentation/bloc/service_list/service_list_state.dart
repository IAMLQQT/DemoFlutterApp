part of 'service_list_bloc.dart';

sealed class ServiceListState {
  const ServiceListState();
}

final class ServiceListLoading extends ServiceListState {
  const ServiceListLoading();
}

final class ServiceListLoaded extends ServiceListState {
  const ServiceListLoaded({required this.categories, required this.activeCategoryId});

  final List<ServiceCategory> categories;
  final String activeCategoryId;

  List<ServiceItem> get services =>
      categories.where((c) => c.id == activeCategoryId).firstOrNull?.services ?? const [];

  /// List data for one service, used to paint the detail header instantly.
  ServiceItem? findService(String id) {
    for (final category in categories) {
      for (final service in category.services) {
        if (service.id == id) return service;
      }
    }
    return null;
  }

  ServiceListLoaded copyWith({String? activeCategoryId}) => ServiceListLoaded(
        categories: categories,
        activeCategoryId: activeCategoryId ?? this.activeCategoryId,
      );
}

final class ServiceListFailure extends ServiceListState {
  const ServiceListFailure(this.message);
  final String message;
}
