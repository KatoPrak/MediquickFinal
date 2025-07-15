// apotek_role/product_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/apotek_role/add_product_screen.dart';
import 'package:mediquick/apotek_role/edit_product_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final apotekId = prefs.getInt('apotek_id');

    if (apotekId == null) {
      print("apotek_id tidak ditemukan di SharedPreferences");
      return;
    }

    final response = await http.get(
      Uri.parse(
        'http://mediquick.my.id/products/read_by_apotek.php?apotek_id=$apotekId',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          products = data['data'];
          isLoading = false;
        });
      }
    } else {
      print('Gagal load produk: ${response.statusCode}');
    }
  }

  Future<void> _deleteProduct(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final apotekId = prefs.getInt('apotek_id'); // ambil ID dari login

    if (apotekId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus: apotek_id tidak ditemukan'),
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://mediquick.my.id/products/delete.php'),
      body: {
        'id': id.toString(),
        'apotek_profile_id': apotekId.toString(), // ✅ HARUS dikirim
      },
    );

    final data = jsonDecode(response.body);
    if (data['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus')));
      _loadProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Gagal menghapus produk')),
      );
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menghapus produk ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteProduct(id);
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
              if (result == true) _loadProducts();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
              ? const Center(child: Text('Belum ada produk'))
              : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading:
                          (p['gambar_url'] != null &&
                                  p['gambar_url'].toString().isNotEmpty)
                              ? Image.network(
                                p['gambar_url'].toString(),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image),
                              )
                              : const Icon(Icons.image_not_supported),

                      title: Text(p['nama']),
                      subtitle: Text(
                        'Stok: ${p['stok']} | Harga: Rp ${p['harga']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => EditProductScreen(productData: p),
                                ),
                              );
                              if (result == true) _loadProducts();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(p['id']),
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
