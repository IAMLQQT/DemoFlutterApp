part of 'service_detail_bloc.dart';

sealed class ServiceDetailState {
  const ServiceDetailState();
}

final class ServiceDetailLoading extends ServiceDetailState {
  const ServiceDetailLoading();
}

final class ServiceDetailLoaded extends ServiceDetailState {
  const ServiceDetailLoaded(this.detail);
  final ServiceDetail detail;
}

final class ServiceDetailFailure extends ServiceDetailState {
  const ServiceDetailFailure(this.failure);
  final Failure failure;
}
