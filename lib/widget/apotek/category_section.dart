// widget/apotek/category_section.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/screens/apotek/produk_detail_screen.dart';

class CategoryApotekSection extends StatelessWidget {
  const CategoryApotekSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'iconPath': 'assets/images/tablet.png', 'label': 'Tablet'},
      {'iconPath': 'assets/images/kapsul.png', 'label': 'Kapsul'},
      {'iconPath': 'assets/images/puyer.jpg', 'label': 'Puyer'},
      {'iconPath': 'assets/images/sirup.png', 'label': 'Sirup'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jenis Obat', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children:
                categories.map((item) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProdukByJenisScreen(jenis: item['label']!),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(item['iconPath']!),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['label']!,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

// ===============================
// SCREEN PRODUK BY JENIS
// ===============================
class ProdukByJenisScreen extends StatefulWidget {
  final String jenis;
  const ProdukByJenisScreen({super.key, required this.jenis});

  @override
  State<ProdukByJenisScreen> createState() => _ProdukByJenisScreenState();
}

class _ProdukByJenisScreenState extends State<ProdukByJenisScreen> {
  List<dynamic> _produk = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

  Future<void> _fetchProduk() async {
    final url = Uri.parse(
      'http://mediquick.my.id/products/filter_by_jenis.php?jenis=${widget.jenis}',
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['success']) {
        setState(() {
          _produk = data['data'];
          _loading = false;
        });
      } else {
        _showError(data['message']);
      }
    } else {
      _showError('Gagal mengambil data');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.jenis}'),
        backgroundColor: Colors.teal,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _produk.isEmpty
              ? const Center(child: Text('Tidak ada produk tersedia'))
              : ListView.builder(
                itemCount: _produk.length,
                itemBuilder: (_, i) {
                  final p = _produk[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProductDetailScreen(
                                productId: int.parse(
                                  p['id'].toString(),
                                ), // pastikan id dalam int
                              ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              p['gambar_url'] != null &&
                                      p['gambar_url'].toString().isNotEmpty
                                  ? Image.network(
                                    p['gambar_url'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                  : const Icon(Icons.image_not_supported),
                        ),
                        title: Text(
                          p['nama'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text('Rp${p['harga']}   Stok: ${p['stok']}'),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
