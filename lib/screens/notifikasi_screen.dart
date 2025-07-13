import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
    final authState = context.read<AuthBloc>().state;
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
        actions: [
          BlocBuilder<NotifikasiBloc, NotifikasiState>(
            builder: (context, state) {
              if (state is NotifikasiLoaded && state.notif.any((n) => n.status == 'belum dibaca')) {
                return TextButton(
                  onPressed: () {
                    if (authState is Authenticated) {
                      context.read<NotifikasiBloc>().add(
                        MarkAllAsRead(token: authState.token),
                      );
                    }
                  },
                  child: const Text(
                    'Baca Semua',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<NotifikasiBloc, NotifikasiState>(
              builder: (context, notifState){
                if(authState is Authenticated &&
                    (notifState is! NotifikasiLoaded || notifState.notif.isEmpty || notifState is NotifikasiInitial)){
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
                      return GestureDetector(
                        onTap: () => _showNotificationDetail(context, notification),
                        child: _buildNotificationCard(notification),
                      );
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
                    DateFormat('d MMMM y, HH:mm').format(notification.waktu),
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

  void _showNotificationDetail(BuildContext context, NotifikasiModel notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: Stack(
              children: [
                // Blurred background with icon
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Opacity(
                    opacity: 0.1,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: Icon(
                        notification.icon == "celebration" ? Icons.celebration : Icons.quiz,
                        color: notification.warna == 'purple' ? Colors.purple : Colors.green,
                        size: 80,
                      ),
                    ),
                  ),
                ),
                // Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.judul,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('d MMMM y, HH:mm').format(notification.waktu),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              notification.pesan,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Full-width OK Button at bottom
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is Authenticated) {
                            context.read<NotifikasiBloc>().add(
                              MarkAsRead(id: notification.id, token: authState.token),
                            );
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}