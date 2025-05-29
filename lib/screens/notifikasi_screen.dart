import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/notifikasi/notifikasi_bloc.dart';
import 'package:project_ta/bloc/notifikasi/notifikasi_event.dart';
import 'package:project_ta/bloc/notifikasi/notifikasi_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/notifikasi_model.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  _NotifikasiScreenState createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<NotifikasiBloc, NotifikasiState>(
            builder: (context, notifState){
              if(authState is Authenticated &&
                  (notifState is! NotifikasiLoaded || notifState.notif.isEmpty)){
                Future.microtask(() {
                  context.read<NotifikasiBloc>().add(FetchNotifikasi(token: authState.token));
                });
              }

              if(notifState is NotifikasiLoaded){
                final allNotifikasi = notifState.notif;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: allNotifikasi.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = allNotifikasi[index];
                    return _buildNotificationCard(notification);
                  },
                );
              }
              else if (notifState is NotifikasiLoading) {
                return Center(child: CircularProgressIndicator());
              }
              else if (notifState is NotifikasiError) {
                return Center(child: Text(notifState.message));
              }
              else{
                return Center(child: Text(""));
              }
            }
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotifikasiModel notification) {
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
                color: notification.warna == 'purple' ? Colors.purple.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.icon == "celebration" ? Icons.celebration : Icons.quiz,
                color: notification.warna == 'purple' ? Colors.purple : Colors.green,
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
                    notification.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.pesan,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.waktu.toString(),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Indikator baca
            if (notification.status == 'belum dibaca')
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