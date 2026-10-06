class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.bannerUrl,
    required this.shareLink,
    this.isHot = false,
  });

  final String id;
  final String title;
  final String thumbnailUrl;
  final String bannerUrl;
  final String shareLink;
  final bool isHot;
}