import 'package:flutter/material.dart';

class EducationSearchBar extends StatelessWidget {
  final Function(String)? onChanged;

  const EducationSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: "Temukan",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            width: 48,
            margin: const EdgeInsets.only(right: 0),
            decoration: BoxDecoration(
              color: Color(0xFF7FA1C3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
