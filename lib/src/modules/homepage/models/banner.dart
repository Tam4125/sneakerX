class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String backgroundColor;
  final String buttonText;
  final int displayOrder;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.backgroundColor,
    required this.buttonText,
    required this.displayOrder,
  });
}