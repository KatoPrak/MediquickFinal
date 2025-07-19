import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/admin/admin_dashboard.dart';
import 'package:mediquick/apotek_role/apotek_dashboard.dart';
import 'package:mediquick/mixpanel_service.dart';
import 'package:mediquick/screens/login/forgot_password_screen.dart';
import 'package:mediquick/screens/navigasi_screen.dart';
import 'package:mediquick/screens/register/register_screen.dart';
import 'package:mediquick/service/location_service.dart';
import 'package:mediquick/widget/login/custom_text_field.dart';
import 'package:mediquick/widget/login/social_login_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> afterLoginSuccess() async {
    try {
      final position = await LocationService.determinePosition();
      final address = await LocationService.getAddressFromPosition(position);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alamat_user', address);
      await prefs.setDouble('latitude_user', position.latitude);
      await prefs.setDouble('longitude_user', position.longitude);
    } catch (e) {
      print("Gagal ambil lokasi: $e");
    }
  }

  Future<void> _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await http.post(
          Uri.parse("http://mediquick.my.id/login.php"),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "email": _emailController.text.trim(),
            "password": _passwordController.text.trim(),
          }),
        );

        final dynamic data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          await afterLoginSuccess();
          _handleSuccessResponse(data);
        } else {
          _showErrorSnackbar(data['message'] ?? 'Login gagal.');
        }
      } catch (e) {
        _showErrorSnackbar("Kesalahan jaringan: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _handleSuccessResponse(dynamic data) async {
    try {
      final token = data['token']?.toString();
      final userData = data['data'];

      final prefs = await SharedPreferences.getInstance();
      final role = userData['role'].toString().toLowerCase();

      await prefs.setString('token', token ?? '');
      await prefs.setString('userData', jsonEncode(userData));
      await prefs.setString('role', role);
      await prefs.setString('id', userData['id'].toString());
      await prefs.setString('nama', userData['name'].toString());
      await prefs.setString('email', userData['email'].toString());

      /// 🔵 Mixpanel Integration
      final mixpanel = MixpanelService.instance;

      mixpanel.identify(userData['id'].toString());

      mixpanel.getPeople().set('name', userData['name']);
      mixpanel.getPeople().set('email', userData['email']);
      mixpanel.getPeople().set('role', role);
      mixpanel.getPeople().set('last_login', DateTime.now().toIso8601String());

      mixpanel.track(
        'User Logged In',
        properties: {
          'email': userData['email'],
          'role': role,
          'login_time': DateTime.now().toIso8601String(),
        },
      );

      if (role == 'apotek') {
        final apotekProfileResponse = await http.get(
          Uri.parse(
            "http://mediquick.my.id/users/get_apotek_profile.php?user_id=${userData['id']}",
          ),
        );

        if (apotekProfileResponse.statusCode == 200) {
          final apotekData = jsonDecode(apotekProfileResponse.body);
          if (apotekData['success']) {
            await prefs.setString(
              'apotek_profile_id',
              apotekData['apotek_profile_id'].toString(),
            );
            await prefs.setInt(
              'apotek_id',
              int.parse(apotekData['apotek_profile_id'].toString()),
            );
            await prefs.setString(
              'pharmacy_name',
              apotekData['pharmacy_name'] ?? '',
            );
          }
        }
      }

      _navigateBasedOnRole(role);
    } catch (e) {
      _showErrorSnackbar("Gagal login: ${e.toString()}");
      await _clearSession();
    }
  }

  void _navigateBasedOnRole(String role) {
    final Map<String, Widget> roleScreens = {
      'admin': const AdminDashboardScreen(),
      'apotek': const ApotekDashboardScreen(),
      'user': const MainScreen(),
    };

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => roleScreens[role]!),
      (route) => false,
    );
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(key: _formKey, child: _buildLoginForm()),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        const Text(
          "Masuk",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          "Masuk untuk pengalaman terbaik dengan MediQuick",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        CustomTextField(
          controller: _emailController,
          hintText: "Email",
          isPassword: false,
          prefixIcon: Icons.email,
          validator: _validateEmail,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _passwordController,
          hintText: "Kata Sandi",
          isPassword: true,
          prefixIcon: Icons.lock,
          validator: _validatePassword,
        ),
        const SizedBox(height: 10),
        _buildRememberMeSection(),
        const SizedBox(height: 10),
        _buildLoginButton(),
        const SizedBox(height: 25),
        const _OrDivider(),
        const SizedBox(height: 25),
        _buildSocialLoginButtons(),
        const SizedBox(height: 20),
        const _RegisterPrompt(),
      ],
    );
  }

  Widget _buildRememberMeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged:
                  (value) => setState(() => _rememberMe = value ?? false),
            ),
            const Text("Ingat saya"),
          ],
        ),
        TextButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
          child: const Text(
            "Lupa kata sandi?",
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _validateAndLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6482AD),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "Masuk",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        SocialLoginButton(
          text: "Masuk dengan Google",
          iconPath: "assets/icons/google.png",
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text("Memproses...", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email harus diisi";
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Format email tidak valid";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Kata sandi harus diisi";
    return null;
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(thickness: 2, color: Colors.grey[600])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Atau dengan", style: TextStyle(color: Colors.grey[600])),
        ),
        Expanded(child: Divider(thickness: 2, color: Colors.grey[600])),
      ],
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Belum punya akun?"),
          TextButton(
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
            child: const Text(
              "Daftar",
              style: TextStyle(color: Color(0xFF6482AD)),
            ),
          ),
        ],
      ),
    );
  }
}
