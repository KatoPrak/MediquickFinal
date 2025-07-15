// screens/apotek/add_address_screen.dart
import 'package:flutter/material.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController detailAddressController = TextEditingController();

  // Dropdown values
  String? selectedProvince;
  String? selectedCity;
  String? selectedDistrict;
  String? selectedSubdistrict;

  final List<String> provinces = ['Kepulauan Riau'];
  final List<String> cities = [
    'Kota Batam',
    'Kota Tanjung Pinang',
    'Kab Anambas',
    'Kab Lingga',
    'Kab Natuna',
    'Kab Bintan',
  ];
  final List<String> districts = ['Batam Kota', 'Sekupang', 'Nongsa'];
  final List<String> subdistricts = ['Belian', 'Patam Lestari'];

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final addressText =
          '${detailAddressController.text}, ${selectedSubdistrict ?? ''}, ${selectedDistrict ?? ''}, ${selectedCity ?? ''}, ${selectedProvince ?? ''}';

      Navigator.pop(context, {
        'name': nameController.text,
        'phone': phoneController.text,
        'address': addressText,
      });
    }
  }

  // Form boxes
  Widget _buildFormBox({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF5EDED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              hintText: 'Tulis jawaban anda',
              hintStyle: TextStyle(color: Colors.grey),
              border: UnderlineInputBorder(),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF7FA1C3), width: 2),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? '$label tidak boleh kosong'
                        : null,
          ),
        ],
      ),
    );
  }

  // Dropdown boxes
  Widget _buildDropdownBox({
    required String label,
    required String? selectedValue,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF5EDED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: selectedValue,
            isExpanded: true,
            hint: Text("Pilih $label"),
            items:
                items
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            validator: (value) => value == null ? '$label harus dipilih' : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Tambah Alamat',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildFormBox(
                label: 'Nama Lengkap',
                hint: 'Isikan nama anda',
                controller: nameController,
              ),
              const SizedBox(height: 20),
              _buildFormBox(
                label: 'Nomor Telepon',
                hint: 'Isikan nomor telepon anda',
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              _buildDropdownBox(
                label: 'Provinsi',
                selectedValue: selectedProvince,
                items: provinces,
                onChanged: (value) => setState(() => selectedProvince = value),
              ),
              const SizedBox(height: 20),
              _buildDropdownBox(
                label: 'Kota/Kabupaten',
                selectedValue: selectedCity,
                items: cities,
                onChanged: (value) => setState(() => selectedCity = value),
              ),
              const SizedBox(height: 20),
              _buildDropdownBox(
                label: 'Kecamatan',
                selectedValue: selectedDistrict,
                items: districts,
                onChanged: (value) => setState(() => selectedDistrict = value),
              ),
              const SizedBox(height: 20),
              _buildDropdownBox(
                label: 'Kelurahan',
                selectedValue: selectedSubdistrict,
                items: subdistricts,
                onChanged:
                    (value) => setState(() => selectedSubdistrict = value),
              ),
              const SizedBox(height: 20),
              _buildFormBox(
                label: 'Nama Perumahan & No Rumah',
                hint: 'Masukkan Detail Lainnya',
                controller: detailAddressController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7FA1C3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Alamat',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
