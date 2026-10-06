import '../../domain/entities/service_category.dart';
import 'service_item_model.dart';

class ServiceCategoryModel  {
  const ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.sort,
    this.items = const [],
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    final groups = json['news'] as List<dynamic>? ?? const [];
    return ServiceCategoryModel(
      id: json['id'] as String ,
      name: (json['name'] as String? ?? '').trim(),
      image: json['image'] as String? ?? '',
      sort: json['sort'] as int? ?? 0,
      items: [
        for (final group in groups) 
          for (final item in (group as Map<String, dynamic>)['items'] as List<dynamic>? ?? const [])
            ServiceItemModel.fromJson(item as Map<String, dynamic>)
      ],
    );
  }
  final String id;
  final String name;
  final String image;
  final int sort;
  final List<ServiceItemModel> items;

  bool get isHot => name.toUpperCase().contains('HOT');

  ServiceCategory toEntity() => ServiceCategory(
        id: id,
        name: name,
        iconUrl: image,
        isHot: isHot,
        services: items.map((m) => m.toEntity()).toList(),
      );
  
}