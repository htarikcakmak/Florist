class Vendor {
  final String id;
  final String name;
  final String logoPath;
  final String coverPath;
  final double rating;
  final String deliveryTime;
  final double shippingCost; 
  final String workingHours; 

  Vendor({
    required this.id,
    required this.name,
    required this.logoPath,
    required this.coverPath,
    required this.rating,
    required this.deliveryTime,
    required this.shippingCost,
    required this.workingHours,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: (json['id'] ?? 0).toString(),
      name: json['name'] ?? '',
      logoPath: json['logoPath'] ?? json['logo_path'] ?? '',
      coverPath: json['coverPath'] ?? json['cover_path'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      deliveryTime: json['deliveryTime'] ?? json['delivery_time'] ?? '30-45 dk',
      shippingCost: (json['shippingCost'] ?? json['shipping_cost'] ?? 0).toDouble(),
      workingHours: json['workingHours'] ?? json['working_hours'] ?? '09:00 - 18:00',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'logoPath': logoPath,
    'coverPath': coverPath,
    'rating': rating,
    'deliveryTime': deliveryTime,
    'shippingCost': shippingCost,
    'workingHours': workingHours,
  };
}