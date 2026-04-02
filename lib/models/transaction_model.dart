class TransactionModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String annonceId;
  final DateTime createdAt;
  final String status; // 'pending', 'completed', 'failed'

  TransactionModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.annonceId,
    required this.createdAt,
    this.status = 'pending',
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String documentId) {
    return TransactionModel(
      id: documentId,
      fromUserId: json['fromUserId'] ?? '',
      toUserId: json['toUserId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      annonceId: json['annonceId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'annonceId': annonceId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
