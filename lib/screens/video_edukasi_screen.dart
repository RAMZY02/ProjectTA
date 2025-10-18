import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_event.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_state.dart';
import 'package:project_ta/constants/color.dart';

import '../bloc/auth/auth_state.dart';

class VideoEdukasiScreen extends StatelessWidget {
  const VideoEdukasiScreen({super.key});

  // Fungsi untuk mendapatkan icon berdasarkan mata pelajaran
  IconData _getSubjectIcon(String title) {
    if (title.contains('Islam')) return Icons.mosque;
    if (title.contains('Hindu')) return Icons.temple_hindu;
    if (title.contains('Kristen')) return Icons.church;
    if (title.contains('Katolik')) return Icons.church;
    if (title.contains('Pancasila') || title.contains('Kewarganegaraan')) return Icons.flag;
    if (title.contains('Bahasa Indonesia')) return Icons.language;
    if (title.contains('Bahasa Inggris')) return Icons.translate;
    if (title.contains('Matematika')) return Icons.calculate;
    if (title.contains('IPA')) return Icons.science;
    if (title.contains('IPS')) return Icons.public;
    if (title.contains('PJOK')) return Icons.sports;
    if (title.contains('Seni') || title.contains('Budaya')) return Icons.palette;
    if (title.contains('Informatika') || title.contains('TIK')) return Icons.computer;
    return Icons.menu_book; // Default
  }

  // Fungsi untuk mendapatkan warna icon
  Color _getSubjectColor(String title) {
    if (title.contains('Agama')) return Colors.green;
    if (title.contains('Pancasila') || title.contains('Kewarganegaraan')) return Colors.red;
    if (title.contains('Bahasa Indonesia')) return Colors.orange;
    if (title.contains('Bahasa Inggris')) return Colors.blue;
    if (title.contains('Matematika')) return Colors.indigo;
    if (title.contains('IPA')) return Colors.purple;
    if (title.contains('IPS')) return Colors.brown;
    if (title.contains('PJOK')) return Colors.teal;
    if (title.contains('Seni') || title.contains('Budaya')) return Colors.pink;
    if (title.contains('Informatika') || title.contains('TIK')) return Colors.cyan;
    return Colors.grey; // Default
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Video Edukasi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: BlocBuilder<MataPelajaranBloc, MataPelajaranState>(
          builder: (context, mapelSate) {
            if(mapelSate is MataPelajaranInitial && authState is Authenticated){
              context.read<MataPelajaranBloc>().add(FetchMataPelajaranSiswa(id_user: authState.id, token: authState.token));
            }
            if(mapelSate is MataPelajaranLoaded){
              return ListView.builder(
                itemCount: mapelSate.mataPelajaranList.length,
                itemBuilder: (context, index) {
                  final matapelajaran = mapelSate.mataPelajaranList[index];
                  return Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pushNamed(
                            context,
                            "/daftar-video",
                            arguments: matapelajaran.mapel
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Logo Mata Pelajaran
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getSubjectColor(matapelajaran.mapel).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getSubjectIcon(matapelajaran.mapel),
                                color: _getSubjectColor(matapelajaran.mapel),
                                size: 40,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Konten Ujian
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    matapelajaran.mapel,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D47A1),
                                        fontSize: 16
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              );
            }
            else if(mapelSate is MataPelajaranLoading){
              return Center(child: CircularProgressIndicator());
            }
            else if(mapelSate is MataPelajaranError){
              return Center(child: Text('Error : ${mapelSate.message}'));
            }
            else{
              return Center(child: Text('GG'));
            }
          }
      ),
    );
  }
}