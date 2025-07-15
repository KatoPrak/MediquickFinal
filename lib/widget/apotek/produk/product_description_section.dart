// widget/apotek/produk/product_description_section.dart
import 'package:flutter/material.dart';

class ProductDescriptionSection extends StatelessWidget {
  final String description;

  const ProductDescriptionSection({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text('📌 Detail Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(description.isNotEmpty ? description : 'Tidak ada deskripsi tersedia'),
        const SizedBox(height: 40),
      ],
    );
  }
}
