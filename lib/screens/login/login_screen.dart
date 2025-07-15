// screens/login/login_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mediquick/admin/admin_dashboard.dart';
import 'package:mediquick/apotek_role/apotek_dashboard.dart';
import 'package:mediquick/screens/login/forgot_password_screen.dart';
import 'package:mediquick/screens/navigasi_screen.dart';
import 'package:mediquick/screens/register/register_screen.dart';
import 'package:mediquick/service/location_service.dart';
import 'package:mediquick/widget/login/custom_text_field.dart';
import 'package:mediquick/widget/login/social_login_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  void _handleErrorResponse(dynamic data) {
    final errorMessage =
        data['message']?.toString() ?? 'Terjadi kesalahan. Silakan coba lagi.';
    _showErrorSnackbar(errorMessage);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
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

      print("Alamat tersimpan: \$address");
    } catch (e) {
      print("Gagal ambil lokasi: \$e");
    }
  }

  Future<void> saveAutoDetectedAddress() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark p = placemarks.first;
        String formatted = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auto_address', formatted);
        await prefs.setString('auto_name', 'Lokasi Saya');
        await prefs.setString(
          'auto_phone',
          '08123456789',
        ); // optional, bisa diisi user
      }
    } catch (e) {
      debugPrint('Gagal mendeteksi lokasi: $e');
    }
  }

  Future<void> _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await http
            .post(
              Uri.parse("http://mediquick.my.id/login.php"),
              headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
              },
              body: jsonEncode({
                "email": _emailController.text.trim(),
                "password": _passwordController.text.trim(),
              }),
            )
            .timeout(const Duration(seconds: 10));

        final dynamic data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          await afterLoginSuccess();
          _handleSuccessResponse(data);
        } else {
          _handleErrorResponse(data);
        }
      } on SocketException catch (e) {
        _showErrorSnackbar(
          "Tidak dapat terhubung ke server. Periksa jaringan.",
        );
        debugPrint("SocketException: \$e");
      } on FormatException catch (e) {
        _showErrorSnackbar("Format data tidak valid: \${e.message}");
      } on http.ClientException {
        _showErrorSnackbar("Gagal terhubung ke server");
      } catch (e) {
        _showErrorSnackbar("Terjadi kesalahan tak terduga: \$e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _handleSuccessResponse(dynamic data) async {
    debugPrint("Full API Response: \${data.toString()}");
    try {
      final token = data['token']?.toString();
      final userData = data['data'];

      if (token == null || userData == null) {
        throw const FormatException("Respon server tidak valid");
      }

      final requiredFields = ['id', 'email', 'role'];
      for (final field in requiredFields) {
        if (userData[field] == null) {
          throw FormatException("Field \$field tidak ditemukan");
        }
      }

      final role = userData['role'].toString().toLowerCase().trim();
      if (!['admin', 'apotek', 'user'].contains(role)) {
        throw FormatException("Role tidak valid: \$role");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userData', jsonEncode(userData));
      await prefs.setString('role', role);
      await prefs.setString('id', userData['id'].toString());
      await prefs.setString('nama', userData['nama'].toString());
      await prefs.setString('email', userData['email'].toString());

      if (role == 'apotek') {
        final apotekProfileResponse = await http.get(
          Uri.parse(
            "http://mediquick.my.id/users/get_apotek_profile.php?user_id=${userData['id']}",
          ),
        );

        debugPrint("RESPON PROFIL APOTEK: ${apotekProfileResponse.body}");

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
            debugPrint(
              "✅ apotek_profile_id disimpan: ${apotekData['apotek_profile_id']}",
            );
          } else {
            debugPrint(
              "⚠️ Gagal ambil profil apotek: ${apotekData['message']}",
            );
          }
        } else {
          debugPrint("⚠️ HTTP Error: ${apotekProfileResponse.statusCode}");
        }
      }

      _navigateBasedOnRole(role);
    } catch (e) {
      _showErrorSnackbar(e.toString());
      await _clearSession();
    }
  }

  void _navigateBasedOnRole(String role) {
    debugPrint("Role Received: \$role");
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            fontSize: 14,
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        SocialLoginButton(
          text: "Masuk dengan Facebook",
          iconPath: "assets/icons/facebook.png",
          onPressed: () => _handleSocialLogin('facebook'),
        ),
        const SizedBox(height: 16),
        SocialLoginButton(
          text: "Masuk dengan Google",
          iconPath: "assets/icons/google.png",
          onPressed: () => _handleSocialLogin('google'),
        ),
      ],
    );
  }

  void _handleSocialLogin(String provider) {
    // Implement social login logic
  }

  Widget _buildLoadingOverlay() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              "Memproses...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Atau dengan", style: TextStyle(color: Colors.grey[600])),
        ),
        const Expanded(child: Divider(thickness: 2)),
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
            child: const Text("Daftar", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
