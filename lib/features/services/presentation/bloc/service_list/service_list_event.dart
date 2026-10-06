part of 'service_list_bloc.dart';

sealed class ServiceListEvent {
  const ServiceListEvent();
}

/// Load categories the first time the screen opens.
final class ServiceListStarted extends ServiceListEvent {
  const ServiceListStarted();
}

/// Pull-to-refresh or "Thử lại" after an error.
final class ServiceListRefreshed extends ServiceListEvent {
  const ServiceListRefreshed();
}

final class ServiceCategorySelected extends ServiceListEvent {
  const ServiceCategorySelected(this.categoryId);
  final String categoryId;
}
