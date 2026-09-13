class Review {
  final int? id;
  final int userId;
  final String userName;
  final int flowerId;
  final int storeId;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;

  Review({
    this.id,
    required this.userId,
    required this.userName,
    required this.flowerId,
    required this.storeId,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'] ?? 'Anonim',
      flowerId: json['flowerId'],
      storeId: json['storeId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'flowerId': flowerId,
    'storeId': storeId,
    'rating': rating,
    'comment': comment,
  };
}
