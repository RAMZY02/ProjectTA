import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/constants/color.dart';
import '../models/video_edukasi_model.dart';

class ListHistoryVideo extends StatelessWidget {
  final VideoEdukasiModel video;
  final DateTime time;
  final VoidCallback onTap;

  const ListHistoryVideo({
    super.key,
    required this.video,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                video.thumbnail != '-' && video.thumbnail.isNotEmpty
                    ? video.thumbnail
                    : "https://dummy-url.com", // URL dummy untuk memicu error
                height: 140,
                width: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assets/icons/default-course.png",
                    height: 140,
                    width: 110,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 220,
                  child: Text(
                    video.judul,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: Text(
                    '${video.mapel} • Kelas ${video.kelas}',
                    style: TextStyle(fontSize: 10, color: kPrimaryColor),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 15),
                    Text(_formatDate(time), style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 16),
                    const Icon(Icons.remove_red_eye_outlined, size: 15),
                    Text(' ${video.views} views', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            )
          ],
        )
    );
  }

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat('d MMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return DateFormat('d MMM yyyy').format(date); // Fallback format
    }
  }
}