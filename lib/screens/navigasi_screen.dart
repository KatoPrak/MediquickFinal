// screens/navigasi_screen.dart
import 'package:flutter/material.dart';
import 'package:mediquick/screens/ambullance/ambulance_list_screen.dart'; // ← tambahkan ini
import 'package:mediquick/screens/apotek/apotek_screen.dart';
import 'package:mediquick/screens/kelas/kelas_screen.dart';
import '../widget/bottom_navbar.dart';
import 'dashboard/dashboard_screen.dart';
import 'edukasi/edukasi_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(key: ValueKey(0)),
    EducationScreen(key: ValueKey(1)),
    KelasScreen(key: ValueKey(2)),
    ApotekScreen(key: ValueKey(3)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDED),
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AmbulanceListScreen()),
            );
          },
          backgroundColor: const Color(0xFF6482AD),
          shape: const CircleBorder(),
          child: Image.asset('assets/icons/ambulance.png', width: 36, height: 36),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
