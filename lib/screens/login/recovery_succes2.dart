// screens/login/recovery_succes2.dart
import 'package:flutter/material.dart';
import 'package:mediquick/screens/login/login_screen.dart';

class RecoverySuccess2Screen extends StatelessWidget {
  const RecoverySuccess2Screen({super.key});

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
              // Kotak putih
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
                    // Icon Checklist Hijau
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 25,
                      child: Icon(Icons.check, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 30),

                    // Judul
                    const Text(
                      "Berhasil Mengatur Ulang\nKata Sandi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol kembali ke beranda
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7FA1C3),
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Kembali Ke Beranda",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -225,
                child: Image.asset('assets/images/panda.png', height: 400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
