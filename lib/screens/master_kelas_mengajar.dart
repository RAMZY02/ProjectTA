import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_bloc.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_event.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'insert_kelas_mengajar_screen.dart';

class MasterKelasMengajarScreen extends StatefulWidget {
  const MasterKelasMengajarScreen({super.key});

  @override
  State<MasterKelasMengajarScreen> createState() => _MasterKelasMengajarScreenState();
}

class _MasterKelasMengajarScreenState extends State<MasterKelasMengajarScreen> {

  void _deleteKelasMengajar(int id, AuthState state) {
    if(state is Authenticated){
      context.read<KelasMengajarBloc>().add(DeleteKelasMengajar(token: state.token, id: id));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kelas mengajar berhasil dihapus')),
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
      appBar: AppBar(
        title: const Text('Master Kelas Mengajar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Kelas Mengajar'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InsertKelasMengajarScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // DataTable
            Expanded(
                child: BlocBuilder<KelasMengajarBloc, KelasMengajarState>(
                    builder: (context, kelasMengajarState){
                      if(authState is! Authenticated){
                        return const Center(child: Text("Silakan login terlebih dahulu"));
                      }
                      if (kelasMengajarState is KelasMengajarInitial) {
                        Future.microtask(() {
                          context.read<KelasMengajarBloc>().add(FetchAllKelasMengajar(token: authState.token));
                        });
                      }
                      if(kelasMengajarState is KelasMengajarLoaded){
                        if(kelasMengajarState.kelasMengajarList.isEmpty){
                          return const Center(child: Text("Belum ada data kelas mengajar tersedia"));
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
                                  DataColumn(label: Text('ID User')),
                                  DataColumn(label: Text('Kelas')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(
                                    label: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text('Aksi'),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: kelasMengajarState.kelasMengajarList.map((kelasMengajar) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(kelasMengajar.id.toString())),
                                      DataCell(Text(kelasMengajar.idUser.toString())),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 200),
                                          child: Text(
                                            kelasMengajar.kelas,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(kelasMengajar.keyStatus),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getStatusText(kelasMengajar.keyStatus),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                                    builder: (context) => InsertKelasMengajarScreen(
                                                      kelasMengajarData: kelasMengajar,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteKelasMengajar(kelasMengajar.id, authState),
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
                      else if(kelasMengajarState is KelasMengajarError){
                        return Center(child: Text(kelasMengajarState.message));
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