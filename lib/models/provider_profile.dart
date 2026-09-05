class ProviderProfile {
  final int id;
  final String userId;
  final String displayName;
  final String category;
  final String? phone;
  final String? city;
  final String? district;
  final String? bio;
  final int? hourlyRate;
  final double avgRating;
  final int ratingCount;
  final int jobsCompleted;
  final bool verified;
  final DateTime createdAt;

  const ProviderProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.category,
    this.phone,
    this.city,
    this.district,
    this.bio,
    this.hourlyRate,
    this.avgRating = 0,
    this.ratingCount = 0,
    this.jobsCompleted = 0,
    this.verified = false,
    required this.createdAt,
  });

  factory ProviderProfile.fromMap(Map<String, dynamic> map) {
    return ProviderProfile(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      displayName: map['display_name'] as String,
      category: map['category'] as String,
      phone: map['phone'] as String?,
      city: map['city'] as String?,
      district: map['district'] as String?,
      bio: map['bio'] as String?,
      hourlyRate: map['hourly_rate'] as int?,
      avgRating: (map['avg_rating'] as num?)?.toDouble() ?? 0,
      ratingCount: map['rating_count'] as int? ?? 0,
      jobsCompleted: map['jobs_completed'] as int? ?? 0,
      verified: map['verified'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'display_name': displayName,
        'category': category,
        'phone': phone,
        'city': city,
        'district': district,
        'bio': bio,
        'hourly_rate': hourlyRate,
      };
}
