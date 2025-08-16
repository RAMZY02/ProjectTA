import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_state.dart';
import 'package:project_ta/screens/daftar_siswa_screen.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/ujian/ujian_event.dart';

class KoreksiScreen extends StatelessWidget {
  const KoreksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Ujian'),
      ),
      body: BlocBuilder<UjianBloc, UjianState>(
        builder: (context, ujianState){
          if (authState is Authenticated && ujianState is UjianInitial) {
            Future.microtask(() {
              context.read<UjianBloc>().add(FetchUjian2(token: authState.token));
            });
          }

          if(ujianState is UjianLoaded){
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ujianState.ujianList.length,
              itemBuilder: (context, index) {
                final ujian = ujianState.ujianList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DaftarSiswaScreen(ujian: ujian),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ujian.nama,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Tanggal: ${_formatDate(ujian.tanggal)}'),
                          Text('Waktu: ${formatTimeOfDay(ujian.mulai)} - ${formatTimeOfDay(ujian.selesai)}'),
                          Text('Durasi: ${ujian.durasi.toString().substring(0, 7)}'),
                          Text('Jumlah Soal: ${ujian.jumlahSoal}'),
                          const SizedBox(height: 8),
                          Text(
                            ujian.deskripsi,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          else if (ujianState is UjianLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (ujianState is UjianError) {
            return Center(child: Text(ujianState.message));
          }
          else {
            return const Center(child: Text(""));
          }
        }
      )
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

  String formatTimeOfDay(TimeOfDay time) {
    // Format jam dan menit dengan leading zero
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute'; // Format 10.00
  }
}