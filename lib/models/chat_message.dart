class ChatMessage {
  final int? id;
  final int userId;
  final String message;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    this.id,
    required this.userId,
    required this.message,
    required this.isFromUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'message': message,
      'isFromUser': isFromUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      userId: map['userId'],
      message: map['message'],
      isFromUser: map['isFromUser'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
