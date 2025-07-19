// widget/apotek/search_bar.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/main.dart' as MixpanelManager;
import 'package:mediquick/screens/apotek/produk_detail_screen.dart';
import 'search_results_page.dart';

class SearchBarApotek extends StatefulWidget {
  const SearchBarApotek({super.key});

  @override
  State<SearchBarApotek> createState() => _SearchBarApotekState();
}

class _SearchBarApotekState extends State<SearchBarApotek> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];

  void _onTextChanged(String keyword) async {
    if (keyword.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    // ⬇ Track keyword yang diketik
    MixpanelManager.mixpanel.track(
      "Search Typed",
      properties: {"keyword": keyword, "source": "Apotek SearchBar"},
    );

    final url = Uri.parse(
      'http://mediquick.my.id/products/search.php?query=$keyword',
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['success']) {
        setState(() => _suggestions = data['data']);
      }
    }
  }

  void _submitSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      // ⬇ Track submit pencarian
      MixpanelManager.mixpanel.track(
        "Search Submitted",
        properties: {"keyword": query, "source": "Apotek SearchBar"},
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchResultsPage(query: query)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE2DAD6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Input Text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _controller,
                    onChanged: _onTextChanged,
                    onSubmitted: (_) => _submitSearch(),
                    decoration: const InputDecoration(
                      hintText: "Cari nama produk",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // Icon Search
              InkWell(
                onTap: _submitSearch,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 48,
                  width: 48,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7FA1C3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Saran realtime (dropdown style)
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  leading:
                      item['gambar_url'] != null
                          ? Image.network(
                            item['gambar_url'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.image),
                  title: Text(item['nama']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ProductDetailScreen(
                              productId: int.parse(item['id'].toString()),
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
