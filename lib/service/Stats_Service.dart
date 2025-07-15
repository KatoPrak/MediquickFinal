// service/Stats_Service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mediquick/admin/model/StatsModel.dart';

class StatService {
  static const String _baseUrl =
      'http://mediquick.my.id/api_stats.php';

  Future<StatModel> fetchStats() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      return StatModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load stats');
    }
  }
}
