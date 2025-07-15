// service/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/chat_message.dart';

class ChatService {
  final String baseUrl = 'http://mediquick.my.id/chatbox';

  Future<int?> createOrGetChat(int userId, int apotekId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_or_get_chat.php'),
      body: {
        'user_id': userId.toString(),
        'apotek_id': apotekId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return int.tryParse(data['chat_id']?.toString() ?? '0');
      }
    }
    return null;
  }

  Future<bool> sendMessage(int chatId, int senderId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat_send_message.php'),
      body: {
        'chat_id': chatId.toString(),
        'sender_id': senderId.toString(),
        'message': message,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }

    return false;
  }

  Future<List<ChatMessage>> getMessages(int chatId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_messages.php?chat_id=$chatId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['messages'] as List)
            .map((msg) => ChatMessage.fromJson(msg))
            .toList();
      }
    }

    return [];
  }
}
