// widget/onboarding/onboarding_widget.dart
import 'package:flutter/material.dart';
import 'navigation_button.dart';

class OnboardingWidget extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  const OnboardingWidget({super.key, 
    required this.image,
    required this.title,
    required this.description,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Image.asset('assets/images/logo.png', height: 50),
          ),
        ),
        SizedBox(height: 20),
        Image.asset(image, height: 250),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalPages,
            (i) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: currentPage == i ? 16 : 8,
              decoration: BoxDecoration(
                color: currentPage == i ? Color(0xFF6482AD) : Colors.grey,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        //Box biru
        Expanded(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF7FA1C3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -20,
                right: -20,
                child: NavigationButton(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onNext: onNext,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
