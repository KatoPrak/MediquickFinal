// apotek_role/add_product_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _stokController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  // Dropdown untuk jenis obat
  final List<String> _jenisOptions = ['Tablet', 'Kapsul', 'Puyer', 'Sirup'];
  String? _selectedJenis; // nilai dipilih dari dropdown

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final apotekId = prefs.getInt('apotek_id');

    if (apotekId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mendapatkan ID Apotek')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse('http://mediquick.my.id/products/add_product.php');
    final request = http.MultipartRequest('POST', uri);

    request.fields['nama'] = _namaController.text;
    request.fields['harga'] = _hargaController.text;
    request.fields['jenis'] = _selectedJenis ?? ''; // dari dropdown
    request.fields['deskripsi'] = _deskripsiController.text;
    request.fields['stok'] = _stokController.text;
    request.fields['apotek_id'] = apotekId.toString();


    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('gambar', _selectedImage!.path),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (data['success']) {
        final newProductId = data['id'];
        print('Produk berhasil ditambahkan dengan ID: $newProductId');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan')),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan produk: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTextField(
                        _namaController,
                        'Nama Produk',
                        'Contoh: Paracetamol',
                        Icons.medication,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _hargaController,
                        'Harga',
                        'Contoh: 12500',
                        Icons.price_change,
                        isNumber: true,
                      ),
                      const SizedBox(height: 12),

                      // Dropdown Jenis Obat
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Jenis Obat',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        value: _selectedJenis,
                        items:
                            _jenisOptions.map((jenis) {
                              return DropdownMenuItem<String>(
                                value: jenis,
                                child: Text(jenis),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedJenis = value);
                        },
                        validator:
                            (value) =>
                                value == null ? 'Pilih jenis obat' : null,
                      ),

                      const SizedBox(height: 12),
                      _buildTextField(
                        _stokController,
                        'Stok',
                        'Contoh: 100',
                        Icons.inventory,
                        isNumber: true,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _deskripsiController,
                        'Deskripsi',
                        'Deskripsi produk',
                        Icons.description,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child:
                      _selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                          : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text('Pilih Gambar Produk'),
                              ],
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitProduct,
                  icon: const Icon(Icons.save),
                  label:
                      _isLoading
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('Simpan Produk'),
                          ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
    );
  }
}
