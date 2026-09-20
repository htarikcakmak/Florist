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

  factory Flower.fromJson(Map<String, dynamic> json) {
    return Flower(
      id: (json['id'] ?? 0).toString(),
      name: json['name'] ?? '',
      nameEn: json['nameEn'],
      nameEs: json['nameEs'],
      price: (json['price'] ?? 0).toDouble(),
      imagePath: json['imagePath'] ?? json['image_path'] ?? json['imageUrl'] ?? '',
      category: json['category'] ?? 'Buket',
      description: json['description'] ?? '',
      descriptionEn: json['descriptionEn'],
      descriptionEs: json['descriptionEs'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'nameEn': nameEn,
    'nameEs': nameEs,
    'price': price,
    'imagePath': imagePath,
    'category': category,
    'description': description,
    'descriptionEn': descriptionEn,
    'descriptionEs': descriptionEs,
  };
}