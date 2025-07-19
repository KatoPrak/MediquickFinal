// widget/apotek/produk/product_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:mediquick/screens/apotek/Cart_Screen.dart';
import 'package:mediquick/screens/apotek/chat_screen.dart';
import 'package:mediquick/widget/apotek/Cart_Provider.dart';
import 'package:provider/provider.dart';
import 'package:mediquick/model/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductBottomBar extends StatelessWidget {
  final VoidCallback onCheckout;
  final bool isCheckoutEnabled;
  final int productId;
  final String name;
  final String imageUrl;
  final int price;
  final int apotekId;
  final String pharmacyName;

  const ProductBottomBar({
    super.key,
    required this.onCheckout,
    required this.isCheckoutEnabled,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.pharmacyName,
    required this.apotekId,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;

        return Container(
          margin: const EdgeInsets.only(bottom: 45),
          color: const Color(0xFFDDE6F0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Chat Button
              SizedBox(
                width: isSmallScreen ? double.infinity : 48,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final userId =
                        int.tryParse(prefs.getString('id') ?? '') ?? 0;

                    if (userId == 0 || apotekId == 0) {
                      debugPrint('❌ User ID atau Apotek ID tidak valid');
                      return;
                    }

                    final url = Uri.parse(
                      'http://mediquick.my.id/chatbox/create_or_get_chat.php',
                    );

                    try {
                      final response = await http.post(
                        url,
                        body: {
                          'user_id': userId.toString(),
                          'apotek_id': apotekId.toString(),
                        },
                      );

                      final data = jsonDecode(response.body);
                      debugPrint('📥 Respon create chat: $data');

                      if (data['success']) {
                        final chatId = int.parse(data['chat_id'].toString());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ChatScreen(
                                  userId: userId,
                                  apotekId: apotekId,
                                  chatId: chatId,
                                  isApotek: false,
                                ),
                          ),
                        );
                      } else {
                        debugPrint('❌ Gagal membuka chat: ${data['message']}');
                      }
                    } catch (e) {
                      debugPrint('❌ Exception buka chat: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7FA1C3),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                    elevation: 0,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              // Keranjang Button
              Flexible(
                flex: 1,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      cart.addItem(
                        CartItem(
                          productId: productId,
                          apotekId: apotekId,
                          name: name,
                          imageUrl: imageUrl,
                          price: price,
                          pharmacyName: pharmacyName,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, color: Color(0xFF7FA1C3)),
                    label: const Text(
                      'Keranjang',
                      style: TextStyle(color: Color(0xFF7FA1C3)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7FA1C3)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),

              // Checkout Button
              Flexible(
                flex: 1,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient:
                        isCheckoutEnabled
                            ? const LinearGradient(
                              colors: [Color(0xFF7FA1C3), Color(0xFF4B6D92)],
                            )
                            : const LinearGradient(
                              colors: [Colors.grey, Colors.grey],
                            ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: isCheckoutEnabled ? onCheckout : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white70,
                    ),
                    child: const Text('Checkout'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
