import 'package:flutter/material.dart';

class ImageCarouselApotek extends StatefulWidget {
  const ImageCarouselApotek({super.key});

  @override
  State<ImageCarouselApotek> createState() => _ImageCarouselApotekState();
}

class _ImageCarouselApotekState extends State<ImageCarouselApotek> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Ganti path gambar sesuai kebutuhan
  final List<String> imagePaths = [
    "assets/images/iklan.jpg",
    "assets/images/iklan.jpg",
    "assets/images/iklan.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _controller,
        itemCount: imagePaths.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return carouselItem(imagePaths[index], index);
        },
      ),
    );
  }

  Widget carouselItem(String imagePath, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // Indikator halaman
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imagePaths.length, (i) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentPage == i
                          ? const Color(0xFF6482AD)
                          : Colors.white,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
