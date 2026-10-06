part of 'service_list_bloc.dart';

sealed class ServiceListState {
  const ServiceListState();
}

final class ServiceListLoading extends ServiceListState {
  const ServiceListLoading();
}

final class ServiceListLoaded extends ServiceListState {
  const ServiceListLoaded({
    required this.categories,
    required this.activeCategoryId,
    this.refreshFailure,
  });

  final List<ServiceCategory> categories;
  final String activeCategoryId;

  /// Set when a refresh failed while data was already on screen: the list stays,
  /// the page shows a SnackBar once.
  final Failure? refreshFailure;

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

  /// Any copy clears [refreshFailure] unless a new one is passed.
  ServiceListLoaded copyWith({String? activeCategoryId, Failure? refreshFailure}) =>
      ServiceListLoaded(
        categories: categories,
        activeCategoryId: activeCategoryId ?? this.activeCategoryId,
        refreshFailure: refreshFailure,
      );
}

final class ServiceListFailure extends ServiceListState {
  const ServiceListFailure(this.failure);
  final Failure failure;
}
