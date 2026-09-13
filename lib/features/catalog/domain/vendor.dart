class Vendor {
  final String id;
  final String name;
  final String logoPath;  // YENİ: Dükkanın küçük logosu
  final String coverPath; // YENİ: Dükkanın geniş kapak fotoğrafı
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
}