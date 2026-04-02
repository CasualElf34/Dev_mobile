class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final double rating;
  final int reviewsCount;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      id: documentId,
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'Utilisateur',
      photoUrl: json['photoUrl'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
