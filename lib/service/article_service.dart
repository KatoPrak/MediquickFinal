// service/article_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/admin/model/article_model.dart';

class ArticleService {
  static const String _baseUrl = 'https://mediquick.my.id/api_article.php';

  Future<List<Article>> getArticles() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body is Map<String, dynamic> &&
          body['status'] == true &&
          body.containsKey('data')) {
        return (body['data'] as List)
            .map((json) => Article.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw Exception(body['error'] ?? 'Gagal mengambil artikel');
      }
    } else {
      throw Exception('Gagal koneksi ke server: ${response.statusCode}');
    }
  }

  Future<Article> createArticle(Article article) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'create', ...article.toJson()}),
      );

      debugPrint('POST status: ${response.statusCode}');
      debugPrint('POST body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return article.copyWith(id: data['id']);
        } else {
          throw Exception(data['error'] ?? 'Gagal membuat artikel');
        }
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Gagal membuat artikel: ${e.toString()}');
    }
  }

  Future<void> updateArticle(Article article) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'update', ...article.toJson()}),
      );

      debugPrint('UPDATE status: ${response.statusCode}');
      debugPrint('UPDATE body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != true) {
          throw Exception(data['error'] ?? 'Gagal update artikel');
        }
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Gagal update artikel: ${e.toString()}');
    }
  }

  Future<void> deleteArticle(int id) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'delete', 'id': id}),
      );

      debugPrint('DELETE status: ${response.statusCode}');
      debugPrint('DELETE body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != true) {
          throw Exception(data['error'] ?? 'Gagal menghapus artikel');
        }
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Gagal menghapus artikel: ${e.toString()}');
    }
  }
}

String _parseErrorMessage(http.Response response) {
  try {
    final body = json.decode(response.body);
    return body['error'] ?? body['message'] ?? 'HTTP ${response.statusCode}';
  } catch (_) {
    return 'HTTP ${response.statusCode}';
  }
}
