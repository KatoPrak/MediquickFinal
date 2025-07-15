import 'package:flutter/material.dart';

class ProductPharmacyInfo extends StatelessWidget {
  final String pharmacyName;
  final String location;

  const ProductPharmacyInfo({
    super.key,
    required this.pharmacyName,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.local_pharmacy, color: Color(0xFF775732)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pharmacyName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              location,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}
