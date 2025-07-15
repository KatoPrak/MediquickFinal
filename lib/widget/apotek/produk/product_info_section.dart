// widget/apotek/produk/product_info_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductInfoSection extends StatelessWidget {
  final String title;
  final int price;

  const ProductInfoSection({
    super.key,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF2A2A2A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          formattedPrice,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(thickness: 1, color: Colors.grey),
      ],
    );
  }
}
