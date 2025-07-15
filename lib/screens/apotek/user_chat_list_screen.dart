// screens/apotek/user_chat_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/screens/apotek/chat_screen.dart';

class UserChatListScreen extends StatefulWidget {
  final int userId;

  const UserChatListScreen({super.key, required this.userId});

  @override
  State<UserChatListScreen> createState() => _UserChatListScreenState();
}

class _UserChatListScreenState extends State<UserChatListScreen> {
  List<dynamic> chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChatList();
  }

  Future<void> fetchChatList() async {
    final url = Uri.parse('http://mediquick.my.id/chatbox/get_chats_by_user.php?user_id=${widget.userId}');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          chats = data['chats'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Gagal mengambil chat user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Saya')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
              ? const Center(child: Text('Belum ada chat'))
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ListTile(
                      title: Text(chat['apotek_name'] ?? 'Apotek'),
                      subtitle: Text(chat['last_message'] ?? '-'),
                      trailing: Text(
                        chat['last_sent'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chat['chat_id'],
                              userId: widget.userId,
                              apotekId: chat['apotek_id'],
                              isApotek: false,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
