// screens/login/recovery_success_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'reset_password_screen.dart';

class RecoverySuccessScreen extends StatefulWidget {
  const RecoverySuccessScreen({super.key});

  @override
  _RecoverySuccessScreenState createState() => _RecoverySuccessScreenState();
}

class _RecoverySuccessScreenState extends State<RecoverySuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Delay sebelum pindah
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1EE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black26),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 25,
                      child: Icon(Icons.check, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Tautan Pemulihan Berhasil",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Kami telah mengirimkan\ntautan ke alamat email yang\nterdaftar untuk memulihkan\nkata sandi Anda",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -225,
                child: Image.asset(
                  'assets/images/panda.png',
                  height: 400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
