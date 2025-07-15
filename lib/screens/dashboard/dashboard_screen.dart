// screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:mediquick/widget/dashboard/category_section.dart';
import 'package:mediquick/widget/dashboard/greeting_section.dart';
import 'package:mediquick/widget/dashboard/image_carousel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: const [
              SizedBox(height: 40),
              GreetingSection(),
              SizedBox(height: 30),
              ImageCarousel(),
              SizedBox(height: 24),
              CategorySection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
