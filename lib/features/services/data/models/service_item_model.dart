
import '../../domain/entities/service_item.dart';

class ServiceItemModel {
  const ServiceItemModel({
    required this.id,
    required this.title,
    required this.img,
    required this.sliderImage,
    required this.shareLink,
    this.isHotNews = false, 
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) => ServiceItemModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        img: json['img'] as String? ?? '',
        sliderImage: json['slider_image'] as String? ?? '',
        shareLink: json['share_link'] as String? ?? '',
        isHotNews: json['is_hot_news'] as bool? ?? false,
      );

  final String id;
  final String title;
  final String img;
  final String sliderImage;
  final String shareLink;
  final bool isHotNews; 

  ServiceItem toEntity() => ServiceItem(
        id: id,
        title: title,
        thumbnailUrl: img,
        bannerUrl: sliderImage.isNotEmpty ? sliderImage : img,
        shareLink: shareLink,
        isHot: isHotNews,
      );  
}
