// admin/model/StatsModel.dart
class StatModel {
  final int totalUser;
  final int totalApotek;

  StatModel({required this.totalUser, required this.totalApotek});

  factory StatModel.fromJson(Map<String, dynamic> json) {
    return StatModel(
      totalUser: json['total_user'] ?? 0,
      totalApotek: json['total_apotek'] ?? 0,
    );
  }
}
