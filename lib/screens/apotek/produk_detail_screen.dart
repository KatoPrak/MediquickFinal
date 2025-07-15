// screens/apotek/produk_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/screens/apotek/checkout_screen.dart';
import 'package:mediquick/widget/apotek/produk/product_bottom_bar.dart';
import 'package:mediquick/widget/apotek/produk/product_description_section.dart';
import 'package:mediquick/widget/apotek/produk/product_image_section.dart';
import 'package:mediquick/widget/apotek/produk/product_info_section.dart';
import 'package:mediquick/widget/apotek/produk/product_pharmacy_info.dart';
import 'package:mediquick/widget/apotek/produk/product_quantity_section.dart';
import 'package:mediquick/model/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;
  String? _errorMessage;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _fetchProductDetail();
  }

  Future<void> _fetchProductDetail() async {
    final url = Uri.parse(
      'http://mediquick.my.id/products/read_detail.php?id=${widget.productId}',
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        setState(() {
          _product = Product.fromJson(data['data']);
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Gagal memuat detail produk';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar:
          _product != null
              ? ProductBottomBar(
                isCheckoutEnabled: true,
                onCheckout: _goToCheckout,
                name: _product!.name,
                imageUrl: _product!.imageUrl!,
                price: _product!.price,
                pharmacyName: _product!.pharmacyName,
                apotekId: _product!.apotekId,
                productId: _product!.id,
              )
              : const SizedBox.shrink(),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _buildProductDetail(),
      ),
    );
  }

  void _goToCheckout() {
    if (_product == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CheckoutScreen(
              productName: _product!.name,
              productImage: _product!.imageUrl!,
              quantity: _quantity, // Gunakan nilai yang dipilih user
              productPrice: _product!.price,
              productId: _product!.id,
              apotekId: _product!.apotekId,
            ),
      ),
    );
  }

  Widget _buildProductDetail() {
    final product = _product!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageSection(imagePath: product.imageUrl!),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                ProductInfoSection(title: product.name, price: product.price),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 12),
                    ProductQuantitySection(
                      quantity: _quantity,
                      onAdd: () => setState(() => _quantity++),
                      onRemove: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 12),
                ProductPharmacyInfo(
                  pharmacyName: product.pharmacyName,
                  location: product.pharmacyLocation,
                ),
                const SizedBox(height: 12),
                const Divider(thickness: 1, color: Colors.grey),
                ProductDescriptionSection(description: product.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
