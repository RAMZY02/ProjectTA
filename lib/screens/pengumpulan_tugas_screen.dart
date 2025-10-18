import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/users/users_bloc.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:project_ta/bloc/users/users_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/tugas_model.dart';
import 'package:project_ta/models/user_model.dart';
import '../bloc/pengumpulan_tugas/pengumpulan_tugas_bloc.dart';
import '../bloc/pengumpulan_tugas/pengumpulan_tugas_event.dart';
import 'detail_pengumpulan_screen.dart';

class PengumpulanTugasScreen extends StatelessWidget {
  final TugasModel tugas;
  final String token;

  const PengumpulanTugasScreen({super.key, required this.tugas, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daftar Pengumpulan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50,
                Colors.grey.shade100,
              ],
            ),
          ),
          child: BlocBuilder<UsersBloc, UsersState>(
            builder: (context, state) {
              if(state is UsersInitial){
                Future.microtask(() {
                  context.read<UsersBloc>().add(FetchPengumpulanUsersByKelas(idTugas: tugas.id, token: token, kelas: tugas.kelas));
                });
              }

              if (state is UsersLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Memuat data pengumpulan...",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is UsersLoaded) {
                final pengumpulanList = state.users;
                List<UserModel> sudahMengupulkanList = [];
                List<UserModel> belumMengupulkanList = [];

                if (pengumpulanList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Belum ada pengumpulan",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Siswa belum mengumpulkan tugas ini",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                else{
                  for(var user in pengumpulanList){
                    if(user.pengumpul){
                      sudahMengupulkanList.add(user);
                    }
                    else{
                      belumMengupulkanList.add(user);
                    }
                  }
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Sudah Mengumpulkan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    if(sudahMengupulkanList.isNotEmpty)...[
                      SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: sudahMengupulkanList.length,
                          itemBuilder: (context, index) {
                            final p = sudahMengupulkanList[index];

                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.green.shade50,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    print("ini tugas");
                                    print(p.tugas!.idTugas);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PengumpulanDetailScreen(p: p),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Icon Status
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green.shade600,
                                            size: 24,
                                          ),
                                        ),

                                        SizedBox(width: 16),

                                        // Informasi Siswa
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.nama,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.blue.shade800,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                              SizedBox(height: 4),

                                              Text(
                                                "Telah mengumpulkan",
                                                style: TextStyle(
                                                  color: Colors.green.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                              SizedBox(height: 4),

                                              Text(
                                                "Dikumpulkan: ${_formatDate(p.tugas!.timestamp)}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Pilihan 1: Badge dengan gradien warna berdasarkan nilai
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            gradient: LinearGradient(
                                              colors: p.tugas!.nilai >= 80
                                                  ? [Colors.green.shade400, Colors.green.shade600] // Nilai tinggi
                                                  : p.tugas!.nilai >= 60
                                                  ? [Colors.orange.shade400, Colors.orange.shade600] // Nilai sedang
                                                  : [Colors.red.shade400, Colors.red.shade600], // Nilai rendah
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: Text(
                                            "${p.tugas!.nilai}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Tidak ada siswa yang telah mengumpulkan",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Belum Mengumpulkan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    if(belumMengupulkanList.isNotEmpty)...[
                      SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: belumMengupulkanList.length,
                          itemBuilder: (context, index) {
                            final p = belumMengupulkanList[index];

                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.grey.shade100,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: null,
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Icon Status
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.pending_outlined,
                                            color: Colors.grey.shade600,
                                            size: 24,
                                          ),
                                        ),

                                        SizedBox(width: 16),

                                        // Informasi Siswa
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.nama,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.blue.shade800,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                              SizedBox(height: 4),

                                              Text(
                                                "Belum mengumpulkan",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Semua siswa telah mengumpulkan",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }

              if (state is UsersError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Terjadi Kesalahan",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<PengumpulanTugasBloc>().add(
                            FetchPengumpulanByTugas(idTugas: tugas.id, token: token)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Coba Lagi",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Center(
                child: Text(
                  "Belum ada data",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              );
            },
          ),
        ),
      )
    );
  }

  String _formatDate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}