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
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.08; // Responsive icon size
    final fontSize = screenWidth * 0.03; // Responsive text size
    final sidePadding = screenWidth * 0.03;

    return BottomAppBar(
      color: const Color(0xFF7FA1C3),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                index: 0,
                imagePath: 'assets/icons/home.png',
                label: 'Home',
                iconSize: iconSize,
                fontSize: fontSize,
              ),
              _buildNavItem(
                context,
                index: 1,
                imagePath: 'assets/icons/edukasi.png',
                label: 'Edukasi',
                iconSize: iconSize,
                fontSize: fontSize,
              ),
              SizedBox(width: screenWidth * 0.12), // Space for FAB
              _buildNavItem(
                context,
                index: 2,
                imagePath: 'assets/icons/kelas.png',
                label: 'Kelas',
                iconSize: iconSize,
                fontSize: fontSize,
              ),
              _buildNavItem(
                context,
                index: 3,
                imagePath: 'assets/icons/toko.png',
                label: 'Apotek',
                iconSize: iconSize,
                fontSize: fontSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String imagePath,
    required String label,
    required double iconSize,
    required double fontSize,
  }) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: SizedBox(
        height: iconSize + fontSize + 10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              color: null,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
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
