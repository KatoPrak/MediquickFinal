import 'package:flutter/material.dart';
import 'package:mediquick/main.dart' as MixpanelManager;

class ClassSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ClassSearchBar({super.key, required this.onChanged});

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
          // Input Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) {
                  // 🔹 Kirim event ke Mixpanel
                  MixpanelManager.mixpanel.track(
                    "Class Search",
                    properties: {
                      'search_keyword': value,
                      'timestamp': DateTime.now().toIso8601String(),
                    },
                  );

                  // Callback ke parent widget
                  onChanged(value);
                },
                decoration: const InputDecoration(
                  hintText: "Cari Kelas",
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

          // Icon Search di kotak terpisah
          Container(
            height: 48,
            width: 48,
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
