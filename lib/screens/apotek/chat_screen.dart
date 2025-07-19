// screens/apotek/chat_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/model/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  final int chatId;
  final int apotekId;
  final bool isApotek;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.apotekId,
    required this.isApotek,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late int chatId;
  List<ChatMessage> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    if (chatId == 0) {
      initChat();
    } else {
      loadMessages();
    }

    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (chatId != 0) loadMessages();
    });
  }

  Future<void> initChat() async {
    final url = Uri.parse(
      'http://mediquick.my.id/chatbox/create_or_get_chat.php',
    );
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': widget.userId.toString(),
          'apotek_id': widget.apotekId.toString(),
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        setState(() {
          chatId = int.tryParse(data['chat_id'].toString()) ?? 0;
        });
        if (chatId != 0) loadMessages();
      } else {
        debugPrint('❌ Gagal init chat: ${data['message']}');
      }
    } catch (e) {
      debugPrint('❌ Exception initChat: $e');
    }
  }

  Future<void> loadMessages() async {
    if (chatId == 0) return;
    final url = Uri.parse(
      'http://mediquick.my.id/chatbox/get_messages.php?chat_id=$chatId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final newMessages = List<ChatMessage>.from(
            data['messages'].map((json) => ChatMessage.fromJson(json)),
          )..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          setState(() {
            messages = newMessages;
          });

          scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('❌ Error loadMessages: $e');
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || chatId == 0) return;

    setState(() => isLoading = true);

    final url = Uri.parse(
      'http://mediquick.my.id/chatbox/chat_send_message.php',
    );
    try {
      final response = await http.post(
        url,
        body: {
          'chat_id': chatId.toString(),
          'sender_role': widget.isApotek ? 'apotek' : 'user',
          'sender_id':
              widget.isApotek
                  ? widget.apotekId.toString()
                  : widget.userId.toString(),
          'message': text,
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        messageController.clear();
        await loadMessages();
        scrollToBottom();
      } else {
        debugPrint('❌ Gagal kirim pesan: ${data['message']}');
        if (data['error'] != null) {
          debugPrint('🧨 Error detail: ${data['error']}');
        }
      }
    } catch (e) {
      debugPrint('❌ Exception sendMessage: $e');
    }

    setState(() => isLoading = false);
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFF6F8FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          widget.isApotek ? 'Chat dengan Pengguna' : 'Chat dengan Apotek',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                final isSenderApotek =
                    message.senderRole == 'apotek' &&
                    message.senderId == widget.apotekId;
                final isSenderUser =
                    message.senderRole == 'user' &&
                    message.senderId == widget.userId;
                final isMe = widget.isApotek ? isSenderApotek : isSenderUser;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF7FA1C3) : Colors.white,
                      gradient:
                          isMe
                              ? const LinearGradient(
                                colors: [Color(0xFF7FA1C3), Color(0xFF4B6D92)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                              : null,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => sendMessage(),
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      filled: true,
                      fillColor: const Color(0xFFF0F2F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ClipOval(
                  child: Material(
                    color: const Color(0xFF7FA1C3),
                    child: InkWell(
                      onTap:
                          isLoading || messageController.text.trim().isEmpty
                              ? null
                              : sendMessage,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child:
                            isLoading
                                ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
