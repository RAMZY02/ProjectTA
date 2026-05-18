import 'package:flutter/material.dart';
import 'package:project_ta/constants/color.dart';
import '../models/video_edukasi_model.dart';

class VideoThumbnailGridCard extends StatelessWidget {
  final VideoEdukasiModel video;
  final VoidCallback onTap;

  const VideoThumbnailGridCard({
    super.key,
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 320,
        constraints: BoxConstraints(
            minHeight: 320,
            maxHeight: 320
        ),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                video.thumbnail != '-' && video.thumbnail.isNotEmpty
                    ? video.thumbnail
                    : "https://dummy-url.com", // URL dummy untuk memicu error
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assets/icons/default-course.png",
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 4.0, right: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Text(
                      video.judul,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IntrinsicHeight(
                      child: Text('${video.mapel} • Kelas ${video.kelas}', style: TextStyle(fontSize: 10, color: kPrimaryColor), maxLines: 2)
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, size: 15),
                      Text(' ${video.likes} likes', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye_outlined, size: 15),
                      Text(' ${video.views} views', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}