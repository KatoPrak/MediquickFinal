// screens/edukasi/edukasi_screen.dart
import 'package:flutter/material.dart';
import 'package:mediquick/admin/model/article_model.dart';
import 'package:mediquick/main.dart';
import 'package:mediquick/service/article_service.dart';
import 'package:mediquick/widget/edukasi/education_card.dart';
import 'package:mediquick/widget/edukasi/education_filter_buttons.dart';
import 'package:mediquick/widget/edukasi/education_search_bar.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedFilter = '';
  String _searchQuery = '';
  List<Article> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
    mixpanel.track(
      "View Article List",
      properties: {
        'source': 'EducationScreen',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _fetchArticles() async {
    try {
      final articles = await ArticleService().getArticles();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat artikel: $e')));
    }
  }

  void _onFilterChanged(String value) {
    setState(() {
      _selectedFilter = value;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        _articles.where((article) {
          final matchesFilter =
              _selectedFilter.isEmpty ||
              article.type.toLowerCase() == _selectedFilter.toLowerCase();
          final matchesSearch = article.title.toLowerCase().contains(
            _searchQuery,
          );
          return matchesFilter && matchesSearch;
        }).toList();

    final pertolongan =
        filtered
            .where((a) => a.type.toLowerCase() == 'pertolongan pertama')
            .toList();
    final artikel =
        filtered
            .where((a) => a.type.toLowerCase() == 'artikel kesehatan')
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5EDED),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              EducationSearchBar(onChanged: _onSearchChanged),
              const SizedBox(height: 16),
              EducationFilterButtons(onFilterChanged: _onFilterChanged),
              const SizedBox(height: 24),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (pertolongan.isNotEmpty) ...[
                  _buildSectionTitle('Pertolongan Pertama'),
                  _buildGrid(pertolongan),
                  const SizedBox(height: 24),
                ],
                if (artikel.isNotEmpty) ...[
                  _buildSectionTitle('Artikel Kesehatan'),
                  _buildGrid(artikel),
                ],
                if (filtered.isEmpty && !_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: Center(child: Text('Data tidak ditemukan.')),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildGrid(List<Article> articles) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return EducationCard(article: articles[index]);
      },
    );
  }
}
