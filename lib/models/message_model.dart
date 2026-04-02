class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String? imageUrl;
  final DateTime sentAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.imageUrl,
    required this.sentAt,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String documentId) {
    return MessageModel(
      id: documentId,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      sentAt: json['sentAt'] != null 
          ? DateTime.parse(json['sentAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'imageUrl': imageUrl,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
