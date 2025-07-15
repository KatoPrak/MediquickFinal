// admin/course/course_form.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CourseForm extends StatefulWidget {
  const CourseForm({super.key});

  @override
  State<CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends State<CourseForm> {
  List _modules = [];

  final _baseUrl = "http://mediquick.my.id/Course/Admin/module_api.php";
  final _uploadUrl = "http://mediquick.my.id/uploads/upload.php";

  @override
  void initState() {
    super.initState();
    fetchModules();
  }

  Future<void> fetchModules() async {
    final response = await http.get(Uri.parse("$_baseUrl?action=read"));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() {
        _modules = decoded['data'] ?? [];
      });
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    final request = http.MultipartRequest("POST", Uri.parse(_uploadUrl));
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final decoded = json.decode(responseBody);

    if (decoded['success'] == true && decoded['url'] != null) {
      return decoded['url'];
    }
    return null;
  }

  Future<void> showModuleForm({Map? module}) async {
    final titleCtrl = TextEditingController(text: module?['title'] ?? '');
    final descCtrl = TextEditingController(text: module?['description'] ?? '');
    final ytCtrl = TextEditingController(text: module?['youtube_url'] ?? '');

    File? localImage;
    String? uploadedUrl = module?['thumbnail_url'];
    final isEdit = module != null;

    List<Map<String, String>> quizList = [];

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setModalState) => AlertDialog(
                  contentPadding: const EdgeInsets.all(16),
                  scrollable: true,
                  title: Text(isEdit ? 'Edit Modul' : 'Tambah Modul'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🧩 Informasi Modul',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Judul',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: ytCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Link YouTube',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child:
                            localImage != null
                                ? Image.file(localImage!, height: 120)
                                : (uploadedUrl != null
                                    ? Image.network(uploadedUrl, height: 120)
                                    : const Icon(Icons.image, size: 100)),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            setModalState(() {
                              localImage = File(picked.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.photo),
                        label: const Text("Pilih Thumbnail"),
                      ),
                      const Divider(height: 30),
                      const Text(
                        '📝 Soal Kuis',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      ...quizList.asMap().entries.map((entry) {
                        int index = entry.key;
                        var quiz = entry.value;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Pertanyaan ${index + 1}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setModalState(
                                          () => quizList.removeAt(index),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Pertanyaan',
                                  ),
                                  onChanged:
                                      (v) => quizList[index]['question'] = v,
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Opsi A',
                                  ),
                                  onChanged:
                                      (v) => quizList[index]['option_a'] = v,
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Opsi B',
                                  ),
                                  onChanged:
                                      (v) => quizList[index]['option_b'] = v,
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Opsi C',
                                  ),
                                  onChanged:
                                      (v) => quizList[index]['option_c'] = v,
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Opsi D',
                                  ),
                                  onChanged:
                                      (v) => quizList[index]['option_d'] = v,
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Jawaban Benar (A/B/C/D)',
                                  ),
                                  onChanged:
                                      (v) =>
                                          quizList[index]['correct_option'] =
                                              v.toUpperCase(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setModalState(() {
                              quizList.add({
                                'question': '',
                                'option_a': '',
                                'option_b': '',
                                'option_c': '',
                                'option_d': '',
                                'correct_option': '',
                              });
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Tambah Soal"),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String? finalThumb = uploadedUrl;
                        if (localImage != null) {
                          final uploaded = await uploadImage(localImage!);
                          if (uploaded != null) {
                            finalThumb = uploaded;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Gagal mengupload gambar"),
                              ),
                            );
                            return;
                          }
                        }

                        final body = {
                          'title': titleCtrl.text,
                          'description': descCtrl.text,
                          'thumbnail_url': finalThumb ?? '',
                          'youtube_url': ytCtrl.text,
                          'quizzes': jsonEncode(quizList),
                        };

                        final url =
                            isEdit
                                ? '$_baseUrl?action=update'
                                : '$_baseUrl?action=create';

                        if (isEdit) body['id'] = module!['id'];

                        await http.post(Uri.parse(url), body: body);
                        Navigator.pop(context);
                        fetchModules();
                      },
                      child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Modul'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> deleteModule(String id) async {
    await http.post(Uri.parse("$_baseUrl?action=delete"), body: {'id': id});
    fetchModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Modul'),
        actions: [
          IconButton(
            onPressed: () => showModuleForm(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body:
          _modules.isEmpty
              ? const Center(child: Text("Belum ada modul"))
              : ListView.builder(
                itemCount: _modules.length,
                itemBuilder: (_, i) {
                  final m = _modules[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: Image.network(
                        m['thumbnail_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                      ),
                      title: Text(m['title']),
                      subtitle: Text(m['description']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => showModuleForm(module: m),
                            icon: const Icon(Icons.edit, color: Colors.orange),
                          ),
                          IconButton(
                            onPressed: () => deleteModule(m['id'].toString()),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
