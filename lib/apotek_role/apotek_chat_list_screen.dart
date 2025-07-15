// apotek_role/apotek_chat_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/screens/apotek/chat_screen.dart';

class ApotekChatListScreen extends StatefulWidget {
  const ApotekChatListScreen({super.key});

  @override
  State<ApotekChatListScreen> createState() => _ApotekChatListScreenState();
}

class _ApotekChatListScreenState extends State<ApotekChatListScreen> {
  List<dynamic> chats = [];
  bool isLoading = true;
  int apotekId = 0;

  @override
  void initState() {
    super.initState();
    loadApotekIdAndFetchChats();
  }

  Future<void> loadApotekIdAndFetchChats() async {
    final prefs = await SharedPreferences.getInstance();
    final idString = prefs.getString('apotek_profile_id');
    final id = int.tryParse(idString ?? '') ?? 0;

    setState(() => apotekId = id);

    if (apotekId != 0) {
      await fetchChatList(apotekId);
    } else {
      setState(() => isLoading = false);
      debugPrint('❌ apotek_profile_id tidak ditemukan di SharedPreferences.');
    }
  }

  Future<void> fetchChatList(int apotekId) async {
    final url = Uri.parse(
      'http://mediquick.my.id/chatbox/get_chats_by_apotek.php?apotek_id=$apotekId',
    );
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      debugPrint('📥 Chat List Response: $data');

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
      debugPrint('❌ Gagal memuat daftar chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Chat Pengguna')),
      body:
          isLoading
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
                          builder:
                              (_) => ChatScreen(
                                chatId: chat['chat_id'],
                                userId: chat['user_id'],
                                apotekId: apotekId,
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
