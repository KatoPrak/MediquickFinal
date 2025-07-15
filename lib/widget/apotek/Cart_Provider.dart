// widget/apotek/Cart_Provider.dart
import 'package:flutter/material.dart';
import 'package:mediquick/model/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Total harga hanya untuk item yang terpilih (isSelected = true)
  int get totalPrice => _items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + (item.price * item.quantity));

  // Menambahkan item ke keranjang
  void addItem(CartItem item) {
    final index = _items.indexWhere((e) => e.name == item.name);
    if (index != -1) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  List<CartItem> get selectedItems =>
      _items.where((item) => item.isSelected).toList();

  // Mengubah jumlah produk
  void updateQuantity(CartItem item, int newQty) {
    item.quantity = newQty;
    notifyListeners();
  }

  // Hapus item
  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  // Hapus semua item
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Toggle centang (isSelected) untuk satu item
  void toggleItemSelection(CartItem item, bool isSelected) {
    item.isSelected = isSelected;
    notifyListeners();
  }

  // Toggle semua item: centang semua / hilangkan semua centang
  void toggleSelectAll(bool selectAll) {
    for (var item in _items) {
      item.isSelected = selectAll;
    }
    notifyListeners();
  }

  // Apakah semua item sudah dicentang
  bool get allSelected => _items.every((item) => item.isSelected);
}
