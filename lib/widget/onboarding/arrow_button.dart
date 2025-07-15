// widget/onboarding/arrow_button.dart
import 'package:flutter/material.dart';

class ArrowButton extends StatelessWidget {
  final VoidCallback onNext;

  const ArrowButton({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onNext,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF6482AD), Color(0xFF7FA1C3)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: Icon(Icons.arrow_forward, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}
