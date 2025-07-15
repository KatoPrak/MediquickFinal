// widget/bottom_navbar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF7FA1C3),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                index: 0,
                imagePath: 'assets/icons/home.png',
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                imagePath: 'assets/icons/edukasi.png',
                label: 'Edukasi',
              ),
              const SizedBox(width: 48),
              _buildNavItem(
                index: 2,
                imagePath: 'assets/icons/kelas.png',
                label: 'Kelas',
              ),
              _buildNavItem(
                index: 3,
                imagePath: 'assets/icons/toko.png',
                label: 'Apotek',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String imagePath,
    required String label,
  }) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: SizedBox(
        height: 55, // <-- Batasi tinggi agar tidak overflow
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              width: 38,
              height: 38,
              fit: BoxFit.contain,
              color: null,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}