part of 'service_detail_bloc.dart';

sealed class ServiceDetailEvent {
  const ServiceDetailEvent();
}

final class ServiceDetailRequested extends ServiceDetailEvent {
  const ServiceDetailRequested(this.serviceId);
  final String serviceId;
}
