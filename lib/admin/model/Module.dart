// admin/model/Module.dart
class Module {
  final int id;
  final String title;
  final String videoUrl;
  final String duration;

  Module({required this.id, required this.title, required this.videoUrl, required this.duration});

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: int.parse(json['id']),
      title: json['title'],
      videoUrl: json['video_url'],
      duration: json['duration'],
    );
  }
}
