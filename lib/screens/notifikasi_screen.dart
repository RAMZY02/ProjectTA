import 'package:flutter/material.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/constants/size.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon notifikasi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: notification.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.icon,
                color: notification.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Konten notifikasi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Indikator baca
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;
  final bool isRead;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
    this.isRead = false,
  });
}

final List<NotificationItem> notifications = [
  NotificationItem(
    icon: Icons.assignment_turned_in,
    title: 'Tugas Baru',
    message: 'Anda mendapat tugas baru untuk mata pelajaran Matematika',
    time: '10 menit yang lalu',
    color: Colors.blue,
    isRead: false,
  ),
  NotificationItem(
    icon: Icons.quiz,
    title: 'Hasil Ujian',
    message: 'Nilai ujian IPA Anda sudah bisa dilihat',
    time: '1 jam yang lalu',
    color: Colors.green,
    isRead: true,
  ),
  NotificationItem(
    icon: Icons.event,
    title: 'Jadwal Baru',
    message: 'Ada perubahan jadwal pelajaran untuk besok',
    time: '3 jam yang lalu',
    color: Colors.orange,
    isRead: true,
  ),
  NotificationItem(
    icon: Icons.celebration,
    title: 'Poin Bertambah',
    message: 'Anda mendapatkan 50 poin dari menyelesaikan tugas',
    time: '5 jam yang lalu',
    color: Colors.purple,
    isRead: false,
  ),
  NotificationItem(
    icon: Icons.group,
    title: 'Permintaan Pertemanan',
    message: 'Budi mengirim permintaan pertemanan',
    time: '1 hari yang lalu',
    color: Colors.red,
    isRead: true,
  ),
];