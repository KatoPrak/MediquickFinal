// screens/apotek/address_screen.dart
import 'package:flutter/material.dart';
import 'package:mediquick/screens/apotek/add_address_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Map<String, String>> savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final autoAddress = prefs.getString('auto_address');
    final autoName = prefs.getString('auto_name') ?? 'Pengguna';
    final autoPhone = prefs.getString('auto_phone') ?? '-';

    if (autoAddress != null && autoAddress.isNotEmpty) {
      setState(() {
        savedAddresses = [
          {'name': autoName, 'phone': autoPhone, 'address': autoAddress},
        ];
      });
    }
  }

  void _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        savedAddresses.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Alamat'),
        backgroundColor: const Color(0xFF7FA1C3),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: savedAddresses.length,
        itemBuilder: (context, index) {
          final address = savedAddresses[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text('${address['name']} - ${address['phone']}'),
              subtitle: Text(address['address'] ?? ''),
              trailing: const Icon(Icons.check),
              onTap: () => Navigator.pop(context, address),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _navigateToAddAddress,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Tambahkan Alamat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8FAAC7),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
