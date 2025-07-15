// admin/article/article_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Tambahkan ini
import 'package:mediquick/admin/model/article_model.dart';
import 'package:mediquick/admin/widget/article_form.dart';
import 'package:mediquick/service/article_service.dart';

class ArticleManagementScreen extends StatefulWidget {
  const ArticleManagementScreen({super.key});

  @override
  _ArticleManagementScreenState createState() => _ArticleManagementScreenState();
}

class _ArticleManagementScreenState extends State<ArticleManagementScreen> {
  final ArticleService _articleService = ArticleService();
  List<Article> _articles = [];
  bool _isLoading = true; // Tambahkan indikator loading eksplisit
  bool _isDeleting = false; // Indikator untuk operasi delete

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);
    
    try {
      final articles = await _articleService.getArticles();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load articles: $e')),
      );
    }
  }

  void _navigateToForm(BuildContext context, [Article? article]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleForm(
          article: article,
          isEdit: article != null,
        ),
      ),
    );
    await _loadArticles();
  }

  Future<void> _deleteArticle(int id) async {
    if (_isDeleting) return; // Cegah multiple clicks
    
    setState(() => _isDeleting = true);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this article?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _articleService.deleteArticle(id);
        // Optimasi: Hapus item lokal tanpa reload semua data
        setState(() {
          _articles.removeWhere((article) => article.id == id);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete article: $e')),
        );
      }
    }
    
    setState(() => _isDeleting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Articles')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _articles.isEmpty
              ? const Center(child: Text('No articles available'))
              : ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return _buildArticleItem(article);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Pisahkan widget untuk optimasi performa
  Widget _buildArticleItem(Article article) {
    return ListTile(
      key: ValueKey(article.id), // Key unik untuk animasi dan optimasi
      leading: article.imageUrl.isNotEmpty
          ? CachedNetworkImage( // Gunakan cached image
              imageUrl: article.imageUrl,
              width: 50,
              height: 50,
              placeholder: (context, url) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 30),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
              fadeInDuration: const Duration(milliseconds: 200),
            )
          : const Icon(Icons.article, size: 50),
      title: Text(
        article.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'By ${article.author} - ${article.publishedDate.toString().substring(0, 10)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToForm(context, article),
          ),
          IconButton(
            icon: _isDeleting
                ? const CircularProgressIndicator()
                : const Icon(Icons.delete),
            onPressed: _isDeleting ? null : () => _deleteArticle(article.id!),
          ),
        ],
      ),
    );
  }
}