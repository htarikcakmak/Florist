class Flower {
  final String id;
  final String name;
  final String? nameEn;
  final String? nameEs;
  final double price;
  final String imagePath;
  final String category;
  final String description;
  final String? descriptionEn;
  final String? descriptionEs;

  Flower({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameEs,
    required this.price,
    required this.imagePath,
    required this.category,
    this.description = '',
    this.descriptionEn,
    this.descriptionEs,
  });
}