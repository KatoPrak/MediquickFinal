// screens/register/register_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/mixpanel_service.dart';
import 'dart:convert';
import 'package:mediquick/screens/login/login_screen.dart';
import 'package:mediquick/widget/register/register_input_field.dart';
import 'package:mediquick/widget/register/register_social_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _validateAndRegister() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse("https://mediquick.my.id/add_users.php");

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "name": name,
            "email": email,
            "password": password,
            "role": "user",
          }),
        );

        final data = jsonDecode(response.body);
        print("Status: ${response.statusCode}");
        print("Response: $data");

        if (data['status'] == "success") {
          /// ✅ Log Mixpanel event
          final mixpanel = MixpanelService.instance;

          mixpanel.identify(email); // pakai email untuk identifikasi
          mixpanel.getPeople().set('name', name);
          mixpanel.getPeople().set('email', email);
          mixpanel.getPeople().set('role', 'user');
          mixpanel.getPeople().set(
            'registered_at',
            DateTime.now().toIso8601String(),
          );

          mixpanel.track(
            'User Registered',
            properties: {
              'email': email,
              'name': name,
              'role': 'user',
              'registered_at': DateTime.now().toIso8601String(),
            },
          );

          _showSuccessDialog(); // tampilkan dialog sukses
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ ${data['message']}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Terjadi kesalahan: $e')));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Registrasi Berhasil!'),
            content: const Text('Silakan login untuk melanjutkan.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Registrasi",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Buat akun sekarang untuk menikmati\nsemua fitur MediQuick",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  RegisterInputField(
                    controller: _nameController,
                    icon: Icons.person,
                    hint: "Username",
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Username harus diisi";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  RegisterInputField(
                    controller: _emailController,
                    icon: Icons.email,
                    hint: "Email",
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Email harus diisi";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  RegisterInputField(
                    controller: _passwordController,
                    icon: Icons.lock,
                    hint: "Kata Sandi",
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Kata sandi harus diisi";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  RegisterInputField(
                    controller: _confirmPasswordController,
                    icon: Icons.lock,
                    hint: "Konfirmasi Kata Sandi",
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Konfirmasi kata sandi harus diisi";
                      if (value != _passwordController.text)
                        return "Kata sandi tidak cocok";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6482AD),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _validateAndRegister,
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 2, color: Colors.grey[600]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Atau dengan",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 2, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RegisterSocialButton(
                    text: "Masuk dengan Google",
                    iconPath: "assets/icons/google.png",
                    onPressed: () {
                      print("Login dengan Google");
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Sudah Punya Akun?",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Masuk",
                            style: TextStyle(color: Color(0xff6482AD)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
