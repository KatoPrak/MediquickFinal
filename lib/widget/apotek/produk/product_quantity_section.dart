import 'package:flutter/material.dart';

class ProductQuantitySection extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductQuantitySection({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF85A8D0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Color(0xFF85A8D0)),
            onPressed: onRemove,
          ),
          Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF85A8D0)),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
