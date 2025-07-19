// screens/apotek/Cart_Screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediquick/screens/apotek/checkout_screen.dart';
import 'package:mediquick/widget/apotek/Cart_Provider.dart';
import 'package:provider/provider.dart';

String formatRupiah(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDED),
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Color(0xFF6482AD),
        elevation: 0,
        centerTitle: true,
        title: const Text('Keranjang', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5EDED),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: item.isSelected,
                        onChanged: (value) {
                          item.isSelected = value ?? false;
                          cart.notifyListeners();
                        },
                      ),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.pharmacyName,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            title: const Text('Hapus Produk'),
                                            content: const Text(
                                              'Apakah kamu yakin ingin menghapus produk ini dari keranjang?',
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text('Batal'),
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                              ),
                                              ElevatedButton(
                                                child: const Text('Hapus'),
                                                onPressed: () {
                                                  cart.removeItem(item);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatRupiah(item.price),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 20),
                                      onPressed: () {
                                        if (item.quantity > 1) {
                                          cart.updateQuantity(
                                            item,
                                            item.quantity - 1,
                                          );
                                        }
                                      },
                                    ),
                                    Text(item.quantity.toString()),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 20),
                                      onPressed: () {
                                        cart.updateQuantity(
                                          item,
                                          item.quantity + 1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: const Color(0xFFDDE3EB),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Consumer<CartProvider>(
                  builder:
                      (_, cart, __) => Row(
                        children: [
                          Checkbox(
                            value: cart.allSelected,
                            onChanged: (value) {
                              cart.toggleSelectAll(value ?? false);
                            },
                          ),
                          const Text('Semua'),
                        ],
                      ),
                ),

                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Total (${cart.items.length} item)"),
                    Text(
                      formatRupiah(cart.totalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed:
                      cart.selectedItems.isEmpty
                          ? null
                          : () {
                            final selectedItem = cart.selectedItems.first;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CheckoutScreen(
                                      productName: selectedItem.name,
                                      productImage: selectedItem.imageUrl,
                                      quantity: selectedItem.quantity,
                                      productPrice: selectedItem.price,
                                      productId: selectedItem.productId,
                                      apotekId: selectedItem.apotekId,
                                    ),
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7FA1C3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
