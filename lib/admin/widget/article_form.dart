// admin/widget/article_form.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/admin/model/article_model.dart';
import 'package:mediquick/service/article_service.dart';

class ArticleForm extends StatefulWidget {
  final bool isEdit;
  final Article? article;

  const ArticleForm({super.key, required this.isEdit, this.article});

  @override
  State<ArticleForm> createState() => _ArticleFormState();
}

class _ArticleFormState extends State<ArticleForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  final _videoUrlController = TextEditingController();

  File? _imageFile;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  String? _selectedType;
  final List<String> _articleTypes = [
    'Pertolongan Pertama',
    'Artikel Kesehatan',
  ];

  final ArticleService _articleService = ArticleService();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.article != null) {
      _titleController.text = widget.article!.title;
      _contentController.text = widget.article!.content;
      _authorController.text = widget.article!.author;
      _videoUrlController.text = widget.article!.videoUrl;
      _selectedType = widget.article!.type;
    }

    _videoUrlController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  bool _isValidYouTubeUrl(String url) {
    final regExp = RegExp(
      r'^(https?\:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+$',
      caseSensitive: false,
    );
    return regExp.hasMatch(url);
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
      );
      if (picked != null && mounted) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      }
    }
  }

  Future<String?> _uploadImageToServer(File imageFile) async {
    try {
      setState(() => _isUploadingImage = true);
      final uri = Uri.parse('https://mediquick.my.id/uploads/upload.php');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();
      late Map<String, dynamic> result;
      try {
        result = json.decode(body);
      } catch (_) {
        throw Exception('Upload gagal: respons tidak valid');
      }

      if (result['success'] == true) {
        return result['url'];
      } else {
        throw Exception(result['message'] ?? 'Upload gagal');
      }
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    if (_imageFile == null &&
        (widget.article?.imageUrl == null ||
            widget.article!.imageUrl.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu.')),
      );
      return;
    }

    if (!_isValidYouTubeUrl(_videoUrlController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan URL YouTube yang valid.')),
      );
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih jenis artikel.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl = widget.article?.imageUrl;

      if (_imageFile != null) {
        imageUrl = await _uploadImageToServer(_imageFile!);
      }

      final article = Article(
        id: widget.article?.id,
        title: _titleController.text,
        content: _contentController.text,
        imageUrl: imageUrl ?? '',
        author: _authorController.text,
        publishedDate: widget.article?.publishedDate ?? DateTime.now(),
        videoUrl: _videoUrlController.text,
        type: _selectedType!,
      );

      if (widget.isEdit) {
        await _articleService.updateArticle(article);
      } else {
        await _articleService.createArticle(article);
      }

      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan artikel: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Berhasil'),
            content: Text(
              widget.isEdit
                  ? 'Artikel berhasil diperbarui!'
                  : 'Artikel berhasil dibuat!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // tutup dialog
                  Navigator.pop(context); // kembali ke halaman sebelumnya
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildImagePreview() {
    if (_isUploadingImage) {
      return const Center(child: CircularProgressIndicator());
    } else if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (widget.article?.imageUrl != null &&
        widget.article!.imageUrl.isNotEmpty) {
      return Image.network(
        widget.article!.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text('Tap untuk pilih gambar', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    final url = _videoUrlController.text;
    if (!_isValidYouTubeUrl(url)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.play_circle_fill,
              size: 50,
              color: Colors.red[700],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Artikel' : 'Tambah Artikel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Isi Artikel'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Konten wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'Nama penulis wajib diisi'
                            : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items:
                    _articleTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedType = val),
                decoration: const InputDecoration(labelText: 'Jenis Artikel'),
                validator:
                    (v) =>
                        v == null || v.isEmpty ? 'Pilih jenis artikel' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Video URL',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'URL video wajib diisi';
                  if (!_isValidYouTubeUrl(v))
                    return 'Masukkan URL YouTube yang valid';
                  return null;
                },
              ),
              _buildVideoPreview(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveArticle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Simpan Artikel',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
