enum AnnonceCategory {
  panne,
  piece,
  conseil
}

class AnnonceModel {
  final String id;
  final String authorId;
  final String title;
  final String description;
  final AnnonceCategory category;
  final List<String> photosUrl;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final double? suggestedPrice;

  AnnonceModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.description,
    required this.category,
    required this.photosUrl,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.suggestedPrice,
  });

  factory AnnonceModel.fromJson(Map<String, dynamic> json, String documentId) {
    return AnnonceModel(
      id: documentId,
      authorId: json['authorId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: AnnonceCategory.values.firstWhere(
        (e) => e.toString() == 'AnnonceCategory.${json['category']}',
        orElse: () => AnnonceCategory.panne,
      ),
      photosUrl: List<String>.from(json['photosUrl'] ?? []),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      createdAt: _parseDateTime(json['createdAt']),
      suggestedPrice: json['suggestedPrice'] != null 
          ? (json['suggestedPrice']).toDouble() 
          : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'photosUrl': photosUrl,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'suggestedPrice': suggestedPrice,
    };
  }
}
