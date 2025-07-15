// widget/notification_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    markNotificationsAsRead(); // ini sudah benar ✅
    fetchNotifications(); // panggil fetch setelah mark read
  }

  Future<void> markNotificationsAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');
    if (userId == null) return;

    final response = await http.post(
      Uri.parse('http://mediquick.my.id/orders/mark_all_as_read.php'),
      body: {'user_id': userId},
    );

    if (response.statusCode == 200) {
      debugPrint("✅ Semua notifikasi ditandai sebagai dibaca");
    } else {
      debugPrint("❌ Gagal menandai notifikasi sebagai dibaca");
    }
  }

  Future<void> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID tidak ditemukan")));
      return;
    }

    final url = Uri.parse(
      'http://mediquick.my.id/orders/get_notifications.php?user_id=$userId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          notifications = data['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal mengambil notifikasi'),
          ),
        );
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal terhubung ke server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(child: Text("Belum ada notifikasi"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Card(
                    elevation: 2,
                    color:
                        notif['is_read'] == '0'
                            ? Colors.blue.shade50
                            : Colors.white,
                    child: ListTile(
                      leading: Icon(
                        notif['is_read'] == '0'
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color:
                            notif['is_read'] == '0' ? Colors.blue : Colors.grey,
                      ),
                      title: Text(
                        notif['title'] ?? 'Notifikasi',
                        style: TextStyle(
                          fontWeight:
                              notif['is_read'] == '0'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notif['message'] ?? ''),
                          const SizedBox(height: 4),
                          Text(
                            notif['created_at'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
