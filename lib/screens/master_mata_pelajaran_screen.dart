import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_event.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'insert_mata_pelajaran_screen.dart';

class MasterMataPelajaranScreen extends StatefulWidget {
  const MasterMataPelajaranScreen({super.key});

  @override
  State<MasterMataPelajaranScreen> createState() => _MasterMataPelajaranScreenState();
}

class _MasterMataPelajaranScreenState extends State<MasterMataPelajaranScreen> {

  void _deleteMataPelajaran(int id, AuthState state) {
    if(state is Authenticated){
      context.read<MataPelajaranBloc>().add(DeleteMataPelajaran(token: state.token, id: id));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mata pelajaran berhasil dihapus')),
    );
  }

  String _getStatusText(String keyStatus) {
    switch (keyStatus) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Nonaktif';
      default:
        return keyStatus;
    }
  }

  Color _getStatusColor(String keyStatus) {
    switch (keyStatus) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Mata Pelajaran'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InsertMataPelajaranScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // DataTable
            Expanded(
                child: BlocBuilder<MataPelajaranBloc, MataPelajaranState>(
                    builder: (context, mataPelajaranState){
                      if(authState is! Authenticated){
                        return const Center(child: Text("Silakan login terlebih dahulu"));
                      }
                      if (mataPelajaranState is MataPelajaranInitial) {
                        Future.microtask(() {
                          context.read<MataPelajaranBloc>().add(FetchAllMataPelajaran(token: authState.token));
                        });
                      }
                      if(mataPelajaranState is MataPelajaranLoaded){
                        if(mataPelajaranState.mataPelajaranList.isEmpty){
                          return const Center(child: Text("Belum ada data mata pelajaran tersedia"));
                        }
                        return ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
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
                                  DataColumn(label: Text('Mata Pelajaran')),
                                  DataColumn(
                                    label: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text('Aksi'),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: mataPelajaranState.mataPelajaranList.map((mataPelajaran) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(mataPelajaran.id.toString())),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 300),
                                          child: Text(
                                            mataPelajaran.mapel,
                                            overflow: TextOverflow.ellipsis,
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
                                                    builder: (context) => InsertMataPelajaranScreen(
                                                      mataPelajaranData: mataPelajaran,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteMataPelajaran(mataPelajaran.id, authState),
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
                      else if(mataPelajaranState is MataPelajaranError){
                        return Center(child: Text(mataPelajaranState.message));
                      }
                      else{
                        return const Center(child: CircularProgressIndicator());
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