// model/chat_message.dart
class ChatMessage {
  final String senderRole;
  final int senderId;
  final String message;
  final DateTime timestamp;
  final String senderName;

  ChatMessage({
    required this.senderRole,
    required this.senderId,
    required this.message,
    required this.senderName,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderRole: json['sender_role'],
      senderId: int.tryParse(json['sender_id'].toString()) ?? 0,
      message: json['message'],
      timestamp: DateTime.parse(json['sent_at']),
      senderName: json['sender_name'] ?? 'Tidak diketahui',
    );
  }
}
