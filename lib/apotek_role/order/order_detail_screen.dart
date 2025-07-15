// apotek_role/order/order_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? order;
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOrderDetails();
  }

  Future<void> loadOrderDetails() async {
    final url = Uri.parse(
      'http://mediquick.my.id/orders/get_order_detail.php?order_id=${widget.orderId}',
    );

    final response = await http.get(url);

    final data = jsonDecode(response.body);
    if (data['success']) {
      setState(() {
        order = data['order'];
        items = data['items'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Gagal memuat pesanan')),
      );
    }
  }

  Future<void> updateOrderStatus(String newStatus) async {
  debugPrint('Mengirim update status: $newStatus');

  final response = await http.post(
    Uri.parse('http://mediquick.my.id/orders/update_status.php'),
    body: {
      'order_id': widget.orderId,
      'status': newStatus,
    },
  );

  debugPrint('Response body: ${response.body}');

  final data = jsonDecode(response.body);

  if (data['success']) {
    setState(() {
      order?['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status diperbarui menjadi $newStatus')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Gagal memperbarui status')),
    );
  }
}


  String formatRupiah(dynamic value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(int.tryParse(value.toString()) ?? 0);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.orange;
      case 'processed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'done':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget buildActionButton(String status) {
    if (status == 'new') {
      return _statusButton('Diproses', 'processed');
    } else if (status == 'processed') {
      return _statusButton('Dikirim', 'shipped');
    } else if (status == 'shipped') {
      return _statusButton('Selesai', 'done');
    }
    return const SizedBox.shrink();
  }

  Widget _statusButton(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => updateOrderStatus(value),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items.map((item) {
            final name = item['product_name'] ?? 'Produk';
            final qty = int.tryParse(item['quantity'].toString()) ?? 0;
            final subtotal = int.tryParse(item['subtotal'].toString()) ?? 0;
            final jenis = item['product_type'] ?? '-';

            return Card(
              child: ListTile(
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text('Jenis: $jenis'), Text('Jumlah: x$qty')],
                ),
                trailing: Text(formatRupiah(subtotal)),
              ),
            );
          }).toList(),
    );
  }

  Widget buildSummary() {
    final total = int.tryParse(order?['total'].toString() ?? '0') ?? 0;
    final shipping =
        int.tryParse(order?['shipping_fee'].toString() ?? '0') ?? 0;
    final service = int.tryParse(order?['service_fee'].toString() ?? '0') ?? 0;
    final subtotal = total - shipping - service;

    return Column(
      children: [
        const Divider(),
        _summaryTile('Subtotal', subtotal),
        _summaryTile('Ongkos Kirim', shipping),
        _summaryTile('Biaya Layanan', service),
        const Divider(),
        ListTile(
          title: const Text(
            'Total',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Text(
            formatRupiah(total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryTile(String title, int value) {
    return ListTile(title: Text(title), trailing: Text(formatRupiah(value)));
  }

  @override
  Widget build(BuildContext context) {
    final status = order?['status'] ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : order == null
              ? const Center(child: Text('Data pesanan tidak ditemukan'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID Pesanan: ${widget.orderId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color: getStatusColor(status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('Tanggal: ${order?['created_at'] ?? '-'}'),
                            const SizedBox(height: 12),
                            const Text(
                              'Alamat Pengiriman:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(order?['address'] ?? '-'),
                            const SizedBox(height: 12),
                            const Text(
                              'Catatan:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(order?['note'] ?? '-'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Daftar Produk:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    buildProductList(),
                    buildSummary(),
                    const SizedBox(height: 12),
                    buildActionButton(status),
                  ],
                ),
              ),
    );
  }
}
