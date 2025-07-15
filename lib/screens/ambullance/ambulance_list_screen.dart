// screens/ambullance/ambulance_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AmbulanceListScreen extends StatefulWidget {
  const AmbulanceListScreen({Key? key}) : super(key: key);

  @override
  State<AmbulanceListScreen> createState() => _AmbulanceListScreenState();
}

class _AmbulanceListScreenState extends State<AmbulanceListScreen> {
  List<dynamic> ambulances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAmbulanceData();
  }

  Future<void> fetchAmbulanceData() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final url = Uri.parse(
        'http://mediquick.my.id/get_nearest_ambulance.php'
        '?lat=${position.latitude}&lng=${position.longitude}',
      );

      final response = await http.get(url);

      try {
        final result = json.decode(response.body);

        if (result['success']) {
          setState(() {
            final data = result['data'];
            ambulances = data is List ? data : [data];
            isLoading = false;
          });
        } else {
          throw Exception(result['message'] ?? 'Gagal mengambil data');
        }
      } catch (_) {
        throw Exception('Data dari server tidak valid:\n${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
      }
    }
  }

  Future<void> _makePhoneCall(String number) async {
    final tel = Uri.parse('tel:$number');
    if (await canLaunchUrl(tel)) {
      await launchUrl(tel);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka aplikasi panggilan')),
      );
    }
  }

  String _formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meter = (distanceInKm * 1000).round();
      return '$meter m dari lokasi Anda';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km dari lokasi Anda';
    }
  }

  Color _getDistanceColor(double distance) {
    if (distance <= 3) {
      return Colors.green;
    } else if (distance <= 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulans Terdekat'),
        backgroundColor: const Color(0xFF6482AD),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ambulances.isEmpty
              ? const Center(child: Text('Tidak ada data ambulance.'))
              : ListView.builder(
                itemCount: ambulances.length,
                itemBuilder: (context, index) {
                  final item = ambulances[index];
                  final distance =
                      double.tryParse(item['distance'].toString()) ?? 0;
                  final isEmergency = item['is_emergency'].toString() == '1';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: isEmergency ? Colors.red[50] : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            isEmergency
                                ? Colors.red.withOpacity(0.1)
                                : _getDistanceColor(distance).withOpacity(0.1),
                        child: Icon(
                          isEmergency
                              ? Icons.warning_amber_rounded
                              : Icons.local_hospital,
                          color:
                              isEmergency
                                  ? Colors.red
                                  : _getDistanceColor(distance),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            item['nama'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isEmergency ? Colors.red[900] : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (isEmergency)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'EMERGENCY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle:
                          isEmergency
                              ? Row(
                                children: [
                                  const Icon(
                                    Icons.phone_in_talk,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['nomor_hp'],
                                    style: TextStyle(
                                      color: Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'HOTLINE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Telp: ${item['nomor_hp']}',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDistance(distance),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _getDistanceColor(distance),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.call,
                          color: isEmergency ? Colors.red : Colors.blueAccent,
                        ),
                        onPressed: () {
                          _makePhoneCall(item['nomor_hp']);
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
