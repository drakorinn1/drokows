class ServiceRequest {
  final int id;
  final String userId;
  final String? customerName;
  final String category;
  final String title;
  final String? description;
  final String? address;
  final String? city;
  final String? district;
  final String? phone;
  final int? budget;
  final String? preferredDate;
  final String status; // open | assigned | completed | cancelled
  final int? providerId;
  final DateTime createdAt;

  const ServiceRequest({
    required this.id,
    required this.userId,
    this.customerName,
    required this.category,
    required this.title,
    this.description,
    this.address,
    this.city,
    this.district,
    this.phone,
    this.budget,
    this.preferredDate,
    this.status = 'open',
    this.providerId,
    required this.createdAt,
  });

  factory ServiceRequest.fromMap(Map<String, dynamic> map) {
    return ServiceRequest(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      customerName: map['customer_name'] as String?,
      category: map['category'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      district: map['district'] as String?,
      phone: map['phone'] as String?,
      budget: map['budget'] as int?,
      preferredDate: map['preferred_date'] as String?,
      status: map['status'] as String? ?? 'open',
      providerId: map['provider_id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
