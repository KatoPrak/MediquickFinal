// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // ⬅️ Tambahkan ini
import 'package:mediquick/widget/apotek/Cart_Provider.dart';
import 'package:mediquick/admin/admin_dashboard.dart';
import 'package:mediquick/apotek_role/apotek_dashboard.dart';
import 'package:mediquick/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ⬅️ Wajib sebelum await
  await initializeDateFormatting(
    'id_ID',
    null,
  ); // ⬅️ Inisialisasi format lokal Indonesia

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Tambahkan provider lain di sini jika dibutuhkan
      ],
      child: const MediQuick(),
    ),
  );
}

class MediQuick extends StatelessWidget {
  const MediQuick({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediQuick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Pastikan SplashScreen sudah ada
      // Rute navigasi global
      routes: {
        '/admin': (context) => const AdminDashboardScreen(),
        '/apotek': (context) => const ApotekDashboardScreen(),
        // Tambah route lain jika perlu
      },
    );
  }
}
