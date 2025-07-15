// apotek_role/edit_product_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const EditProductScreen({super.key, required this.productData});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _stokController;

  File? _gambar;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  final List<String> _jenisOptions = ['Tablet', 'Kapsul', 'Puyer', 'Sirup'];
  String? _selectedJenis;

  @override
  void initState() {
    super.initState();

    _namaController = TextEditingController(text: widget.productData['nama']);
    _hargaController = TextEditingController(
      text: widget.productData['harga'].toString(),
    );
    _deskripsiController = TextEditingController(
      text: widget.productData['deskripsi'],
    );
    _stokController = TextEditingController(
      text: widget.productData['stok'].toString(),
    );

    String jenisFromDB =
        widget.productData['jenis']?.toString().trim().toLowerCase() ?? '';
    _selectedJenis = _jenisOptions.firstWhere(
      (j) => j.toLowerCase() == jenisFromDB,
      orElse: () => '',
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _gambar = File(picked.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final apotekId = prefs.getInt('apotek_id');

    if (apotekId == null) {
      _showError('Gagal mendapatkan ID Apotek');
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse('http://mediquick.my.id/products/update.php');
    var request = http.MultipartRequest('POST', url);
    request.fields['id'] = widget.productData['id'].toString();
    request.fields['nama'] = _namaController.text;
    request.fields['harga'] = _hargaController.text;
    request.fields['jenis'] = _selectedJenis ?? '';
    request.fields['deskripsi'] = _deskripsiController.text;
    request.fields['stok'] = _stokController.text;
    request.fields['apotek_profile_id'] = apotekId.toString(); // 🔧 WAJIB

    if (_gambar != null) {
      request.files.add(
        await http.MultipartFile.fromPath('gambar', _gambar!.path),
      );
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final json = jsonDecode(respStr);

      if (json['success']) {
        if (context.mounted) Navigator.pop(context, true);
      } else {
        _showError(json['message']);
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _gambar != null
                              ? Image.file(
                                  _gambar!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : widget.productData['gambar_url'] != null
                                  ? Image.network(
                                      widget.productData['gambar_url'],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image,
                                              size: 50),
                                    )
                                  : Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.add_a_photo,
                                          size: 40),
                                    ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _namaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Produk',
                          border: border,
                          prefixIcon: const Icon(Icons.medication),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hargaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga',
                          border: border,
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedJenis,
                        hint: const Text('Pilih jenis obat'),
                        items: _jenisOptions.map((jenis) {
                          return DropdownMenuItem(
                            value: jenis,
                            child: Text(jenis),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedJenis = value),
                        decoration: InputDecoration(
                          labelText: 'Jenis Obat',
                          border: border,
                          prefixIcon: const Icon(Icons.category),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Pilih jenis obat'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _stokController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stok',
                          border: border,
                          prefixIcon: const Icon(Icons.inventory),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _deskripsiController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          border: border,
                          alignLabelWithHint: true,
                          prefixIcon: const Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan Perubahan'),
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
