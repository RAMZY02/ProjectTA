import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/nilai_akhir_siswa/nilai_akhir_siswa_state.dart';
import 'package:project_ta/screens/daftar_siswa_kelas_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/nilai_akhir_siswa/nilai_akhir_siswa_bloc.dart';
import '../bloc/nilai_akhir_siswa/nilai_akhir_siswa_event.dart';

class RapotWaliKelasScreen extends StatefulWidget {
  const RapotWaliKelasScreen({super.key});

  @override
  State<RapotWaliKelasScreen> createState() => _RapotWaliKelasScreenState();
}

class _RapotWaliKelasScreenState extends State<RapotWaliKelasScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: authState is Authenticated
            ? Text('Raport Kelas ${authState.wali_kelas}')
            : const Text('Raport Wali Kelas'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<NilaiAkhirSiswaBloc, NilaiAkhirSiswaState>(
            builder: (context, naState){
              if((naState is NilaiAkhirSiswaInitial || naState is NilaiAkhirSiswaLoaded) && authState is Authenticated){
                context.read<NilaiAkhirSiswaBloc>().add(FetchRapotWaliKelas(token: authState.token, kelas: authState.wali_kelas));
              }
              if (naState is NilaiAkhirWaliKelasLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Container untuk tabel dengan scroll horizontal
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) => Colors.blue[50],
                              ),
                              dataRowMinHeight: 50,
                              dataRowMaxHeight: 60,
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(
                                  label: SizedBox(
                                    width: 40,
                                    child: Text(
                                      'No',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 250,
                                    child: Text(
                                      'Mata Pelajaran',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Jumlah Terkirim/Jumlah siswa',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                              rows: naState.mapelData.asMap().entries.map((entry) {
                                final index = entry.key;
                                final mapelStatus = entry.value;

                                // Cari data yang sesuai berdasarkan idMapel
                                final statusList = naState.nilaiAkhirWaliKelasList.where((item) => item.idMapel == mapelStatus.id);
                                final status = statusList.isNotEmpty ? statusList.first : null;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 250,
                                        child: Text(
                                          mapelStatus.mapel,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              status != null && status.jumlahTerkirim > 0
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: status != null && status.jumlahTerkirim > 0
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              status != null
                                                  ? status.mapel.contains('Islam') ? '${status.jumlahTerkirim}/${naState.jumlahSiswaIslam}'
                                                  : status.mapel.contains('Hindu') ? '${status.jumlahTerkirim}/${naState.jumlahSiswaHindu}'
                                                  : status.mapel.contains('Kristen') ? '${status.jumlahTerkirim}/${naState.jumlahSiswaKristen}'
                                                  : status.mapel.contains('Katolik') ? '${status.jumlahTerkirim}/${naState.jumlahSiswaKristen}'
                                                  : '${status.jumlahTerkirim}/${naState.jumlahSiswa}'
                                                  : mapelStatus.mapel.contains('Islam') ? '0/${naState.jumlahSiswaIslam}'
                                                  : mapelStatus.mapel.contains('Hindu') ? '0/${naState.jumlahSiswaHindu}'
                                                  : mapelStatus.mapel.contains('Kristen') ? '0/${naState.jumlahSiswaKristen}'
                                                  : mapelStatus.mapel.contains('Katolik') ? '0/${naState.jumlahSiswaKatolik}'
                                                  : '0/${naState.jumlahSiswa}',
                                              style: TextStyle(
                                                color: status != null && status.jumlahTerkirim > 0
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tombol Lihat Daftar Siswa Kelas
                      if (authState is Authenticated)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DaftarSiswaKelasScreen(
                                  kelas: authState.wali_kelas,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Lihat Daftar Siswa Kelas',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                );
              }
              else if(naState is NilaiAkhirSiswaLoading){
                return Center(child: CircularProgressIndicator());
              }
              else if(naState is NilaiAkhirSiswaError){
                return Center(child: Text('Error : ${naState.message}'));
              }
              return Text('Login bang');
            }
        ),
      )
    );
  }
}