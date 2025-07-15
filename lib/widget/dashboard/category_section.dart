// widget/dashboard/category_section.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mediquick/admin/model/article_model.dart';
import 'package:mediquick/widget/edukasi/article_detail_screen.dart';
import 'package:mediquick/widget/edukasi/lihat_semua_kesehatan.dart';
import 'package:mediquick/widget/edukasi/lihat_semua_pertolongan.dart';

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  return '${date.day.toString().padLeft(2, '0')} '
      '${_monthName(date.month)} ${date.year}';
}

String _monthName(int month) {
  const List<String> bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return bulan[month - 1];
}

class _CategorySectionState extends State<CategorySection> {
  List<Article> pertolonganArticles = [];
  List<Article> kesehatanArticles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      final pertolongan = await fetchByType('Pertolongan Pertama');
      final kesehatan = await fetchByType('Artikel Kesehatan');
      setState(() {
        pertolonganArticles = pertolongan;
        kesehatanArticles = kesehatan;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching articles: $e');
      setState(() => isLoading = false);
    }
  }

  Future<List<Article>> fetchByType(String type) async {
    final url = Uri.parse('https://mediquick.my.id/api_article.php?type=$type');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == true && body['data'] is List) {
        return (body['data'] as List)
            .map((json) => Article.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw Exception('Data artikel tidak ditemukan untuk $type');
      }
    } else {
      throw Exception('Gagal memuat $type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSection("Pertolongan Pertama", pertolonganArticles),
        const SizedBox(height: 20),
        buildSection("Artikel Kesehatan", kesehatanArticles),
      ],
    );
  }

  Widget buildSection(String title, List<Article> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: sectionTitle(title),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : list.isEmpty
                  ? const Center(child: Text('Tidak ada data'))
                  : LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = constraints.maxWidth * 0.5;
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ArticleDetailScreen(article: item),
                                ),
                              );
                            },
                            child: Container(
                              width: cardWidth.clamp(140, 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      item.imageUrl,
                                      width: double.infinity,
                                      height: 110,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 100,
                                                color: Colors.grey,
                                              ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.author,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatDate(item.publishedDate),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }
 
  Widget sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            Widget targetScreen;

            if (title == 'Pertolongan Pertama') {
              targetScreen = const LihatSemuaPertolonganScreen();
            } else if (title == 'Artikel Kesehatan') {
              targetScreen = const LihatSemuaKesehatanScreen();
            } else {
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => targetScreen),
            );
          },
          child: Row(
            children: const [
              Text("Lihat semua", style: TextStyle(color: Colors.black)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 18, color: Colors.black),
            ],
          ),
        ),
      ],
    );
  }
}
