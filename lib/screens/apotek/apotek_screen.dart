// screens/apotek/apotek_screen.dart
import 'package:flutter/material.dart';
import 'package:mediquick/widget/apotek/category_section.dart';
import 'package:mediquick/widget/apotek/header.dart';
import 'package:mediquick/widget/apotek/image_carousel_apotek.dart';
import 'package:mediquick/widget/apotek/popular_products_section.dart.dart';
import 'package:mediquick/widget/apotek/search_bar.dart';

class ApotekScreen extends StatelessWidget {
  const ApotekScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              SizedBox(height: 20),
              ApotekHeader(),
              SizedBox(height: 10),
              SearchBarApotek(),
              SizedBox(height: 24),
              ImageCarouselApotek(),
              SizedBox(height: 10),
              CategoryApotekSection(),
              SizedBox(height: 10),
              PopularProducts(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
