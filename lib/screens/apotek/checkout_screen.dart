// screens/apotek/checkout_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mediquick/screens/Payment/Payment_Screen.dart';
import 'package:mediquick/screens/apotek/address_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediquick/service/order_service.dart';

String formatRupiah(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

class CheckoutScreen extends StatefulWidget {
  final String productName;
  final String productImage;
  final int quantity;
  final int productPrice;
  final int productId;
  final int apotekId;

  const CheckoutScreen({
    super.key,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.productPrice,
    required this.productId,
    required this.apotekId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Map<String, String>? selectedAddress;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> submitOrderAndPay(int totalAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id') ?? '';
    final userEmail = prefs.getString('email') ?? 'guest@mediquick.com';
    final address = selectedAddress?['address'] ?? '';
    final phone = selectedAddress?['phone'] ?? '';
    final name = selectedAddress?['name'] ?? '';
    final note = _noteController.text;

    final items = [
      {
        'product_id': widget.productId,
        'name': widget.productName,
        'price': widget.productPrice,
        'quantity': widget.quantity,
      },
      {
        'product_id': 'shipping',
        'name': 'Biaya Pengiriman',
        'price': 10000,
        'quantity': 1,
      },
      {
        'product_id': 'service',
        'name': 'Biaya Layanan',
        'price': 2000,
        'quantity': 1,
      },
    ];

    try {
      final result = await OrderService.createOrderAndGetSnap(
        userId: userId,
        apotekId:
            widget.apotekId,
        name: name,
        email: userEmail,
        phone: phone,
        address: address,
        note: note,
        items: items,
      );

      if (result['success'] == true && result['snap_url'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebView(snapUrl: result['snap_url']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal membuat pesanan: ${result['message']}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_address');
    if (saved != null) {
      setState(() {
        selectedAddress = Map<String, String>.from(jsonDecode(saved));
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int subtotalProduk = widget.productPrice * widget.quantity;
    const int biayaPengiriman = 10000;
    const int biayaLayanan = 2000;
    final int totalPembayaran = subtotalProduk + biayaPengiriman + biayaLayanan;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F2),
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProductCard(),
                const SizedBox(height: 24),
                _buildAddressSection(),
                const SizedBox(height: 24),
                const Text(
                  "Catatan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Tinggalkan Catatan',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Rincian Pesanan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildPriceRow("Subtotal untuk produk", subtotalProduk),
                _buildPriceRow("Subtotal pengiriman", biayaPengiriman),
                _buildPriceRow("Biaya Layanan", biayaLayanan),
                const Divider(height: 24),
                _buildPriceRow("Total Pembayaran", totalPembayaran, bold: true),
              ],
            ),
          ),
          _buildBottomBar(totalPembayaran),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.productImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatRupiah(widget.productPrice),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('x${widget.quantity}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Alamat", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        selectedAddress == null
            ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7FA1C3),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressScreen(),
                  ),
                );
                if (result != null && result is Map<String, String>) {
                  setState(() => selectedAddress = result);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('selected_address', jsonEncode(result));
                }
              },
              icon: const Icon(Icons.location_on, color: Colors.white),
              label: const Text(
                'Tambahkan Alamat',
                style: TextStyle(color: Colors.white),
              ),
            )
            : GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressScreen(),
                  ),
                );
                if (result != null && result is Map<String, String>) {
                  setState(() => selectedAddress = result);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7FA1C3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.location_on, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedAddress!['name']} | ${selectedAddress!['phone']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedAddress!['address']!,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.4,
                            ),
                            maxLines: null,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildBottomBar(int totalPembayaran) {
    return Container(
      color: const Color(0xFFDDE3EB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total (1 item)", style: TextStyle(fontSize: 12)),
                Text(
                  formatRupiah(totalPembayaran),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed:
                selectedAddress == null
                    ? null
                    : () async {
                      await submitOrderAndPay(totalPembayaran);
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7FA1C3),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Bayar Sekarang",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            formatRupiah(value),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
