import 'package:flutter/material.dart';
import 'package:project_ta/constants/color.dart';
import '../models/video_edukasi_model.dart';

class ListSemuaRekomendasi extends StatelessWidget {
  final VideoEdukasiModel video;
  final VoidCallback onTap;

  const ListSemuaRekomendasi({
    super.key,
    required this.video,
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
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                      maxWidth: 240
                  ),
                  child: IntrinsicHeight(
                    child: Text(
                      video.judul,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: 220
                  ),
                  child: IntrinsicHeight(
                      child: Text('${video.mapel} • Kelas ${video.kelas}', style: TextStyle(fontSize: 10, color: kPrimaryColor), maxLines: 2)
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, size: 15),
                    Text(' ${video.likes} likes', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 16),
                    Icon(Icons.remove_red_eye_outlined, size: 15),
                    Text(' ${video.views} views', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            )
          ],
        )
    );
  }
}
