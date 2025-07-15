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
    if (chatId != 0) {
      loadMessages();
    } else {
      initChat();
    }
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => loadMessages(),
    );
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            chatId = int.tryParse(data['chat_id'].toString()) ?? 0;
          });
          loadMessages();
        }
      }
    } catch (e) {
      debugPrint('Error init chat: $e');
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.jumpTo(
                scrollController.position.maxScrollExtent,
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error load messages: $e');
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          messageController.clear();
          await loadMessages();
        }
      }
    } catch (e) {
      debugPrint('Error send message: $e');
    }

    setState(() => isLoading = false);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isApotek ? 'Chat dengan Pengguna' : 'Chat dengan Apotek',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                debugPrint(
                  "message.senderId: ${message.senderId}, "
                  "senderRole: ${message.senderRole}, "
                  "userId: ${widget.userId}, apotekId: ${widget.apotekId}",
                );

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
                  child: Column(
                    crossAxisAlignment:
                        isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          message.senderRole == 'apotek' ? 'Apotek' : 'User',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message.message,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => sendMessage(),
                    textInputAction: TextInputAction.send,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      isLoading || messageController.text.trim().isEmpty
                          ? null
                          : sendMessage,
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
