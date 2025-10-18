import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_state.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/bloc/ujian/ujian_state.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/screens/insert_ujian_admin_screen.dart';
import 'package:project_ta/screens/insert_ujian_screen.dart';
import 'package:project_ta/screens/master_soal_dan_jawaban_screen.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/soal_ujian/soal_ujian_event.dart';

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
    context.read<SoalUjianBloc>().add(InitSoalUjian());
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
                    builder: (context) => const InsertUjianAdminScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // DataTable
          Expanded(
            child: BlocBuilder<UjianBloc, UjianState>(
              builder: (context, ujianState) {
                if (authState is! Authenticated) {
                  return Text("Login Dulu min");
                }
                if (ujianState is UjianInitial) {
                  Future.microtask(() {
                    context
                        .read<UjianBloc>()
                        .add(FetchUjian2(token: authState.token));
                  });
                }
                if (ujianState is UjianLoaded) {
                  if (ujianState.ujianList.isEmpty) {
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
                      scrollDirection: Axis.vertical, // Scroll vertikal
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // Scroll horizontal
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Nama')),
                            DataColumn(label: Text('Mata Pelajaran')),
                            DataColumn(label: Text('Tingkatan')),
                            DataColumn(label: Text('Kelas')),
                            DataColumn(label: Text('Tipe Ujian')),
                            DataColumn(label: Text('Tipe Soal')),
                            DataColumn(label: Text('Tanggal')),
                            DataColumn(label: Text('Mulai')),
                            DataColumn(label: Text('Selesai')),
                            DataColumn(label: Text('Jumlah Soal')),
                            DataColumn(label: Text('Deskripsi')),
                            DataColumn(label: Text('Kode')),
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
                          rows: ujianState.ujianList.map((ujian) {
                            return DataRow(
                              cells: [
                                DataCell(Text(ujian.id.toString())),
                                DataCell(Text(ujian.nama)),
                                DataCell(Text(
                                    ujian.mapel.length > 22
                                        ? '${ujian.mapel.substring(0, 22)}...'
                                        : ujian.mapel
                                )),
                                DataCell(Center(child: Text(ujian.tingkatan))),
                                DataCell(Center(child: Text(ujian.kelas))),
                                DataCell(Text(ujian.tipe_ujian)),
                                DataCell(Text(ujian.tipe_soal)),
                                DataCell(
                                    Text(_formatDate(ujian.tanggal).toString())),
                                DataCell(Center(
                                    child: Text(
                                        formatTimeOfDay(ujian.mulai).toString()))),
                                DataCell(Center(
                                    child: Text(
                                        formatTimeOfDay(ujian.selesai).toString()))),
                                DataCell(Center(
                                    child: Text(ujian.jumlahSoal.toString()))),
                                DataCell(Text(ujian.deskripsi)),
                                DataCell(Text(ujian.kode)),
                                DataCell(Text(ujian.guru)),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  InsertUjianAdminScreen(
                                                    ujianData: ujian,
                                                    isEdit: true,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteUjian(authState.token, ujian.id),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.error_outline,
                                            color: Colors.grey),
                                        onPressed: () =>
                                            _navigateToSoalScreen(ujian),
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
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat('d MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return DateFormat('d MMMM yyyy')
          .format(date); // Fallback format
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    // Format jam dan menit dengan leading zero
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute'; // Format 10.00
  }
}