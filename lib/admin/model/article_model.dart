// admin/model/article_model.dart
class Article {
  final int? id;
  final String title;
  final String content;
  final String author;
  final String imageUrl;
  final String videoUrl;
  final DateTime? publishedDate;
  final String type;

  Article({
    this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.imageUrl,
    required this.videoUrl,
    this.publishedDate,
    required this.type,
  });

  // Factory method dari JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      title: (json['title'] ?? '').toString().trim(),
      content: (json['content'] ?? '').toString().trim(),
      author: (json['author'] ?? '').toString().trim(),
      imageUrl: (json['image_url'] ?? '').toString().trim(),
      videoUrl: (json['video_url'] ?? '').toString().trim(),
      publishedDate:
          json['published_date'] != null
              ? DateTime.tryParse(json['published_date'].toString())
              : null,
      type: (json['type'] ?? '').toString().trim(),
    );
  }

  // Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'author': author,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'type': type,
      if (publishedDate != null)
        'published_date': publishedDate!.toIso8601String(),
    };
  }

  // Salin objek dengan perubahan opsional
  Article copyWith({
    int? id,
    String? title,
    String? content,
    String? author,
    String? imageUrl,
    String? videoUrl,
    DateTime? publishedDate,
    String? type,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      type: type ?? this.type,
    );
  }
}
