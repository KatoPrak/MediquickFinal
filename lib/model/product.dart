// model/product.dart
class Product {
  final int id;
  final String name;
  final String harga;
  final String jenis;
  final String description;
  final String? imageUrl;
  final int stock;
  final int apotekId;
  final String pharmacyName;
  final String pharmacyLocation;

  Product({
    required this.id,
    required this.name,
    required this.harga,
    required this.jenis,
    required this.description,
    required this.imageUrl,
    required this.stock,
    required this.apotekId,
    required this.pharmacyName,
    required this.pharmacyLocation,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['nama'] ?? '',
      harga: json['harga'].toString(),
      jenis: json['jenis'] ?? '',
      description: json['deskripsi'] ?? '',
      imageUrl: json['gambar_url'],
      stock: int.tryParse(json['stok'].toString()) ?? 0,
      apotekId: int.tryParse(json['apotek_profile_id'].toString()) ?? 0,
      pharmacyName: json['nama_apotek'] ?? '',
      pharmacyLocation: json['alamat_apotek'] ?? '',
    );
  }

  int get price {
    return int.tryParse(harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}
