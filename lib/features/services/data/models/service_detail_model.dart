import '../../domain/entities/booking_action.dart';
import '../../domain/entities/service_detail.dart';

/// `data` of `/news/content/{id}`.
class ServiceDetailModel {
  const ServiceDetailModel({
    required this.id,
    required this.title,
    required this.sliderImg,
    required this.content,
    required this.shareLink,
    this.isShowButton = false,
    this.action,
  });

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) =>
      ServiceDetailModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        sliderImg: json['slider_img'] as String? ?? '',
        content: json['content'] as String? ?? '',
        shareLink: json['share_link'] as String? ?? '',
        isShowButton: json['is_show_button'] as bool? ?? false,
        action: json['action'] == null
            ? null
            : BookingActionModel.fromJson(
                json['action'] as Map<String, dynamic>,
              ),
      );

  final String id;
  final String title;
  final String sliderImg;
  final String content; // full HTML document
  final String shareLink;
  final bool isShowButton;
  final BookingActionModel? action;

  ServiceDetail toEntity() => ServiceDetail(
    id: id,
    title: title,
    bannerUrl: sliderImg,
    contentHtml: content,
    shareLink: shareLink,
    bookingActions: [
      if (isShowButton && (action?.active ?? false)) action!.toEntity(),
    ],
  );
}

class BookingActionModel {
  const BookingActionModel({
    required this.buttonTitle,
    required this.type,
    required this.value,
    this.active = false,
  });

  factory BookingActionModel.fromJson(Map<String, dynamic> json) =>
      BookingActionModel(
        buttonTitle: json['button_title'] as String? ?? 'Đặt lịch',
        type: json['type'] as String? ?? '',
        value: json['value'] as String? ?? '',
        active: json['active'] as bool? ?? false,
      );

  final String buttonTitle;
  final String type;
  final String value;
  final bool active;

  BookingAction toEntity() =>
      BookingAction(label: buttonTitle, type: type, value: value);
}
