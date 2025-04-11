class Video {
  final String id;
  final String title;
  final String subject;
  final String grade;
  final String views;
  final String likes;
  final String thumbnail;
  final String duration;
  final String teacher;

  const Video({
    required this.id,
    required this.title,
    required this.subject,
    required this.grade,
    required this.views,
    required this.likes,
    required this.thumbnail,
    required this.duration,
    required this.teacher,
  });

  // Helper untuk mengubah string likes ke integer
  int get likesCount => int.parse(likes.replaceAll(RegExp(r'[^0-9]'), ''));
}