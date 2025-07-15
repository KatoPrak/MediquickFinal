// widget/onboarding/navigation_button.dart
import 'package:flutter/material.dart';
import 'start_button.dart';
import 'arrow_button.dart';

class NavigationButton extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  const NavigationButton({super.key, 
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        if (currentPage < totalPages - 1)
          ArrowButton(onNext: onNext)
        else
          Transform.translate(
            offset: Offset(-40, 0),
            child: StartButton(onNext: onNext),
          ),
      ],
    );
  }
}
