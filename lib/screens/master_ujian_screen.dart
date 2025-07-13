import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/bloc/ujian/ujian_state.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/screens/insert_ujian_screen.dart';
import 'package:project_ta/screens/master_soal_dan_jawaban_screen.dart';

import '../bloc/auth/auth_state.dart';

class MasterUJianScreen extends StatefulWidget {
  const MasterUJianScreen({super.key});

  @override
  State<MasterUJianScreen> createState() => _MasterUJianScreenState();
}

class _MasterUJianScreenState extends State<MasterUJianScreen> {
  void _deleteUjian(String token, int id) {
    context.read<UjianBloc>().add(DeleteUjian(token: token, id_ujian: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ujian deleted successfully')),
    );
  }

  Future<void> _navigateToSoalScreen(UjianModel ujian) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MasterSoalDanJawabanScreen(ujian: ujian),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tambah Ujian'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InsertUjianScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // DataTable
          Expanded(
            child: BlocBuilder<UjianBloc, UjianState>(
              builder: (context, ujianState){
                if(authState is! Authenticated){
                  return Text("Login Dulu min");
                }
                if (ujianState is! UjianLoaded || ujianState.ujianList.isEmpty || ujianState is UjianInitial) {
                  Future.microtask(() {
                    context.read<UjianBloc>().add(FetchUjian(token: authState.token));
                  });
                }
                if(ujianState is UjianLoaded){
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Tipe')),
                        DataColumn(label: Text('Waktu')),
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Mulai')),
                        DataColumn(label: Text('Selesai')),
                        DataColumn(label: Text('Jumlah Soal')),
                        DataColumn(label: Text('Guru')),
                        DataColumn(
                          label: SizedBox(
                            width: 75,
                            child: Center(
                              child: Text('Actions'),
                            ),
                          ),
                        )
                      ],
                      rows: ujianState.ujianList.map((ujian){
                        return DataRow(
                          cells: [
                            DataCell(Text(ujian.id.toString())),
                            DataCell(Text(ujian.nama)),
                            DataCell(Text(ujian.tipe_ujian)),
                            DataCell(Text(ujian.durasi.toString())),
                            DataCell(Text(ujian.tanggal.toString())),
                            DataCell(Text(ujian.mulai.toString())),
                            DataCell(Text(ujian.selesai.toString())),
                            DataCell(Text(ujian.jumlahSoal.toString())),
                            DataCell(Text(ujian.guru)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InsertUjianScreen(
                                            ujianData: ujian,
                                            isEdit: true,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteUjian(authState.token, ujian.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.error_outline, color: Colors.grey),
                                    onPressed: () => _navigateToSoalScreen(ujian),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
                else{
                  return CircularProgressIndicator();
                }
              }
            )
          ),
        ],
      ),
    );
  }
}