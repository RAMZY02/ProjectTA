import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/tugas/tugas_bloc.dart';
import 'package:project_ta/bloc/tugas/tugas_event.dart';
import 'package:project_ta/bloc/tugas/tugas_state.dart';
import 'package:project_ta/models/tugas_model.dart';
import 'package:project_ta/screens/insert_tugas_admin_screen.dart';

import '../bloc/auth/auth_state.dart';

class MasterTugasScreen extends StatefulWidget {
  const MasterTugasScreen({super.key});

  @override
  State<MasterTugasScreen> createState() => _MasterTugasScreenState();
}

class _MasterTugasScreenState extends State<MasterTugasScreen> {
  void _deleteTugas(String token, int id) {
    context.read<TugasBloc>().add(DeleteTugas(token: token, tugasId: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas deleted successfully')),
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
              label: const Text('Tambah Tugas'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InsertTugasAdminScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // DataTable
          Expanded(
            child: BlocBuilder<TugasBloc, TugasState>(
              builder: (context, tugasState) {
                if (authState is! Authenticated) {
                  return const Text("Login Dulu min");
                }
                if (tugasState is TugasInitial) {
                  Future.microtask(() {
                    context
                        .read<TugasBloc>()
                        .add(FetchTugas(token: authState.token));
                  });
                }
                if (tugasState is TugasLoaded) {
                  if (tugasState.tugas.isEmpty) {
                    return const Center(child: Text("Belum ada data tersedia"));
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
                            DataColumn(label: Text('Kelas')),
                            DataColumn(label: Text('Deskripsi')),
                            DataColumn(label: Text('Link Video')),
                            DataColumn(label: Text('Link Gambar')),
                            DataColumn(label: Text('Link Audio')),
                            DataColumn(label: Text('Link File')),
                            DataColumn(label: Text('Deadline')),
                            DataColumn(label: Text('ID Tahun Pelajaran')),
                            DataColumn(label: Text('ID User')),
                            DataColumn(
                              label: SizedBox(
                                width: 75,
                                child: Center(
                                  child: Text('Actions'),
                                ),
                              ),
                            )
                          ],
                          rows: tugasState.tugas.map((tugas) {
                            return DataRow(
                              cells: [
                                DataCell(Text(tugas.id.toString())),
                                DataCell(Text(tugas.nama)),
                                DataCell(Center(child: Text(tugas.kelas))),
                                DataCell(Text(
                                  tugas.deskripsi.length > 22
                                      ? '${tugas.deskripsi.substring(0, 22)}...'
                                      : tugas.deskripsi,
                                )),
                                DataCell(Text(
                                  tugas.linkVideo != '-'
                                      ? '${tugas.linkVideo!.substring(0, tugas.linkVideo!.length > 15 ? 15 : tugas.linkVideo!.length)}...'
                                      : '-',
                                )),
                                DataCell(Text(
                                  tugas.linkGambar != '-'
                                      ? '${tugas.linkGambar!.substring(0, tugas.linkGambar!.length > 15 ? 15 : tugas.linkGambar!.length)}...'
                                      : '-',
                                )),
                                DataCell(Text(
                                  tugas.linkAudio != '-'
                                      ? '${tugas.linkAudio!.substring(0, tugas.linkAudio!.length > 15 ? 15 : tugas.linkAudio!.length)}...'
                                      : '-',
                                )),
                                DataCell(Text(
                                  tugas.linkFile != '-'
                                      ? '${tugas.linkFile!.substring(0, tugas.linkFile!.length > 15 ? 15 : tugas.linkFile!.length)}...'
                                      : '-',
                                )),
                                DataCell(Text(_formatDate(tugas.deadline))),
                                DataCell(Center(child: Text(tugas.idTahunPelajaran.toString()))),
                                DataCell(Center(child: Text(tugas.idUser.toString()))),
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
                                                  InsertTugasAdminScreen(
                                                    tugasData: tugas,
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
                                            _deleteTugas(authState.token, tugas.id),
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
                } else if (tugasState is TugasError) {
                  return Center(child: Text(tugasState.message));
                } else {
                  return const Center(child: CircularProgressIndicator());
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
      return DateFormat('d MMMM yyyy').format(date); // Fallback format
    }
  }
}