import 'booking_action.dart';

class ServiceDetail {
  const ServiceDetail({
    required this.id,
    required this.title,
    required this.bannerUrl,
    required this.contentHtml,
    required this.shareLink,
    required this.bookingActions,
  });

  final String id;
  final String title;
  final String bannerUrl;
  final String contentHtml;
  final String shareLink;
  final List<BookingAction> bookingActions;
}