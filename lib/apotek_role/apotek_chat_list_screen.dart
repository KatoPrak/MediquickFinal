// apotek_role/apotek_chat_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/screens/apotek/chat_screen.dart';

class ApotekChatListScreen extends StatefulWidget {
  final int apotekId;

  const ApotekChatListScreen({super.key, required this.apotekId});

  @override
  State<ApotekChatListScreen> createState() => _ApotekChatListScreenState();
}

class _ApotekChatListScreenState extends State<ApotekChatListScreen> {
  List<dynamic> chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChatList();
  }

  Future<void> fetchChatList() async {
    final url = Uri.parse('http://mediquick.my.id/chatbox/get_chats_by_apotek.php?apotek_id=${widget.apotekId}');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          chats = data['chats'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Gagal memuat chat list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Chat Pengguna'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
              ? const Center(child: Text('Belum ada chat'))
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ListTile(
                      title: Text(chat['user_name'] ?? 'Pengguna'),
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
                              userId: chat['user_id'],
                              apotekId: widget.apotekId,
                              isApotek: true,
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
