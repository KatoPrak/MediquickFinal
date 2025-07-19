// widget/dashboard/greeting_section.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/screens/login/login_screen.dart';
import 'package:mediquick/widget/Kelola%20Akun/manage_account_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String name;

  User({required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(name: json['name'] ?? 'No Name');
  }
}

class GreetingSection extends StatefulWidget {
  const GreetingSection({super.key});

  @override
  _GreetingSectionState createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<GreetingSection> {
  User? currentUser;
  bool isLoading = true;
  String errorMessage = '';

  Future<void> _fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');

    if (userId == null) {
      setState(() {
        errorMessage = 'ID pengguna tidak ditemukan';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://mediquick.my.id/users/get_user.php?id=$userId"),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          setState(() {
            currentUser = User.fromJson(jsonData['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Gagal mengambil data';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Status gagal: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Terjadi error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // agar bisa lebih tinggi
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4, // 40% tinggi layar
          minChildSize: 0.25,
          maxChildSize: 0.6,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Pengaturan Akun',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Kelola Akun"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageAccountScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Logout"),
                    onTap: () async {
                      Navigator.pop(context); // Tutup bottom sheet
                      final confirm = await showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text("Logout"),
                            content: const Text(
                              "Apakah Anda yakin ingin keluar?",
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.pop(dialogContext, false),
                                child: const Text("Batal"),
                              ),
                              ElevatedButton(
                                onPressed:
                                    () => Navigator.pop(dialogContext, true),
                                child: const Text("Logout"),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirm == true) {
                        _logout();
                      }
                    },
                  ),
                  const SizedBox(height: 24), // 👉 Jarak ekstra bawah
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Text(errorMessage, style: const TextStyle(color: Colors.red));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Halo, Selamat Datang",
              style: TextStyle(fontSize: 24, color: Color(0xFF6482AD)),
            ),
            Text(
              currentUser!.name,
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF6482AD),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF6482AD)),
              onPressed: _showSettingsMenu,
            ),
          ],
        ),
      ],
    );
  }
}
