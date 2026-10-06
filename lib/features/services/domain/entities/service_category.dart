import 'service_item.dart';

class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    required this.iconUrl,
    this.isHot = false,
    this.services= const [],
  });

  final String id;
  final String name;
  final String iconUrl;
  final bool isHot;
  final List<ServiceItem> services;
}
