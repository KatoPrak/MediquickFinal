// widget/apotek/popular_products_section.dart.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/screens/apotek/produk_detail_screen.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  List<dynamic> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('http://mediquick.my.id/products/read_all.php');
    try {
      final response = await http.get(url);
      print('RESPONSE: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _products = data['data'];
            _loading = false;
          });
        } else {
          showError(data['message']);
        }
      } else {
        showError('Gagal memuat produk');
      }
    } catch (e) {
      showError('Terjadi kesalahan: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Telusuri Produk Kami', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
              ? const Center(child: Text('Tidak ada produk tersedia'))
              : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.68,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children:
                    _products.map((product) {
                      return PharmacyCard(
                        productId: product['id'],
                        imagePath: product['gambar_url'] ?? '',
                        title: product['nama'] ?? '',
                        price: 'Rp ${product['harga'] ?? '0'}',
                        pharmacyName: product['nama_apotek'] ?? 'Apotek',
                      );
                    }).toList(),
              ),
        ],
      ),
    );
  }
}

class PharmacyCard extends StatelessWidget {
  final int productId;
  final String imagePath;
  final String title;
  final String price;
  final String pharmacyName;

  const PharmacyCard({
    super.key,
    required this.productId,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.pharmacyName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: productId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imagePath.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imagePath,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 60),
                  ),
                )
                : const Icon(Icons.image, size: 60),
            const SizedBox(height: 14),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(price, style: const TextStyle(color: Colors.teal)),
            const SizedBox(height: 35),
            Text(
              pharmacyName.isNotEmpty ? pharmacyName : 'Apotek',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
