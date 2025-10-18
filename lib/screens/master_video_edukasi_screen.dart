import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_event.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_state.dart';
import 'package:project_ta/screens/insert_video_edukasi_admin_screen.dart';
import '../bloc/auth/auth_state.dart';

class MasterVideoEdukasiScreen extends StatefulWidget {
  const MasterVideoEdukasiScreen({super.key});

  @override
  State<MasterVideoEdukasiScreen> createState() => _MasterVideoEdukasiScreenState();
}

class _MasterVideoEdukasiScreenState extends State<MasterVideoEdukasiScreen> {

  void _deleteVideo(int id, AuthState state) {
    if(state is Authenticated){
      context.read<VideoEdukasiBloc>().add(DeleteVideo(token: state.token, idVideo: id, idUser: state.id));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Video'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InsertVideoEdukasiAdminScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // DataTable
            Expanded(
                child: BlocBuilder<VideoEdukasiBloc, VideoEdukasiState>(
                    builder: (context, videoState){
                      if(authState is! Authenticated){
                        return Text("Login Dulu min");
                      }
                      if (videoState is VideoInitial) {
                        context.read<VideoEdukasiBloc>().add(FetchVideos(token: authState.token, userId: authState.id));
                      }
                      if(videoState is VideoLoaded){
                        if(videoState.videos.isEmpty){
                          return Center(child: Text("Belum ada data tersedia"));
                        }
                        return ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              // Enable mouse drag
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 20,
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('ID User')),
                                  DataColumn(label: Text('Judul')),
                                  DataColumn(label: Text('Mata Pelajaran')),
                                  DataColumn(label: Text('Kelas')),
                                  DataColumn(label: Text('Views'), numeric: true),
                                  DataColumn(label: Text('Likes'), numeric: true),
                                  DataColumn(label: Text('Link Video')),
                                  DataColumn(label: Text('Thumbnail')),
                                  DataColumn(label: Text('Deskripsi')),
                                  DataColumn(
                                    label: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text('Aksi'),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: videoState.videos.map((video) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(video.id.toString())),
                                      DataCell(Text(video.id_user.toString())),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 200),
                                          child: Text(
                                            video.judul,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 120),
                                          child: Text(
                                            video.mapel,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text('Kelas ${video.kelas}')),
                                      DataCell(Center(child: Text(video.views.toString()))),
                                      DataCell(Center(child: Text(video.likes.toString()))),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 150),
                                          child: Text(
                                            video.link_video.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 150),
                                          child: Text(
                                            video.thumbnail.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 200),
                                          child: Text(
                                            video.deskripsi,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => InsertVideoEdukasiAdminScreen(
                                                      videoData: video,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteVideo(video.id, authState),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }
                      else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }
                )
            ),
          ],
        ),
      ),
    );
  }
}