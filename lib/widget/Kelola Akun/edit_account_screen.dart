// widget/Kelola Akun/edit_account_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();

  bool isLoading = false;

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('nama') ?? '';
    emailController.text = prefs.getString('email') ?? '';
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID tidak ditemukan")));
      return;
    }

    final response = await http.post(
      Uri.parse("http://mediquick.my.id/users/update_account.php"),
      body: {
        'user_id': userId,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'old_password': oldPassController.text.trim(),
        'new_password': newPassController.text.trim(),
      },
    );

    setState(() => isLoading = false);

    final res = json.decode(response.body);
    if (res['success']) {
      prefs.setString('name', nameController.text.trim());
      prefs.setString('email', emailController.text.trim());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Berhasil')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    oldPassController.dispose();
    newPassController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF6482AD), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Akun"),
        backgroundColor: const Color(0xFF6482AD),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: buildInputDecoration("Nama", Icons.person),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: buildInputDecoration("Email", Icons.email),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Email tidak boleh kosong' : null,
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Ubah Password (Opsional)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: oldPassController,
                obscureText: true,
                decoration: buildInputDecoration(
                  "Password Lama",
                  Icons.lock_outline,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPassController,
                obscureText: true,
                decoration: buildInputDecoration("Password Baru", Icons.lock),
                validator: (value) {
                  if (oldPassController.text.isNotEmpty &&
                      (value == null || value.length < 6)) {
                    return 'Minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6482AD),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Simpan Perubahan",
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
