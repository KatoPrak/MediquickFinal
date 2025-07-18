import 'package:flutter/material.dart';
import 'package:mediquick/widget/kelas/kelas_detail_screen.dart';

class ClassCardGrid extends StatelessWidget {
  final List<Map<String, dynamic>> classes;

  const ClassCardGrid({super.key, required this.classes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classes.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // Jumlah kolom
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),

      itemBuilder: (context, index) {
        final item = classes[index];
        final title = item['title'] ?? 'Tanpa Judul';
        final imageUrl = item['thumbnail_url'] ?? '';
        final youtubeUrl = item['youtube_url'] ?? '';
        final moduleId = item['id'].toString();
        final description = item['description'] ?? '';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ClassDetailScreen(
                      id: moduleId,
                      title: title,
                      description: description,
                      imageUrl: imageUrl,
                      youtubeUrl: youtubeUrl,
                    ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  // Gambar Thumbnail
                  Expanded(
                    flex: 7,
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            Icons.broken_image,
                            size: 90,
                            color: Colors.grey,
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),

                  // Judul di bawah
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF88A9D3),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
