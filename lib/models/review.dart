class Review {
  final int id;
  final String userId;
  final int providerId;
  final int? requestId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.providerId,
    this.requestId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      providerId: map['provider_id'] as int,
      requestId: map['request_id'] as int?,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
