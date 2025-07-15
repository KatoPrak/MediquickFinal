// model/cart_item.dart

class CartItem {
  final int productId;         // ✅ Tambahkan ini
  final int apotekId;          // ✅ Tambahkan ini
  final String name;
  final String imageUrl;
  final int price;
  final String pharmacyName;
  int quantity;
  bool isSelected;

  CartItem({
    required this.productId,
    required this.apotekId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.pharmacyName,
    this.quantity = 1,
    this.isSelected = true,
  });
}
