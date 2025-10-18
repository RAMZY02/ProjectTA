import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/history_tugas/history_tugas_bloc.dart';
import 'package:project_ta/bloc/history_tugas/history_tugas_event.dart';
import 'package:project_ta/bloc/history_tugas/history_tugas_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/history_tugas_model.dart';

import '../bloc/auth/auth_state.dart';

class HistoryTugasScreen extends StatefulWidget {
  final int tugasId;
  const HistoryTugasScreen({super.key, required this.tugasId});

  @override
  State<HistoryTugasScreen> createState() => _HistoryTugasScreenState();
}

class _HistoryTugasScreenState extends State<HistoryTugasScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History Pengumpulan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor, // Ganti dengan warna primary Anda
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: BlocBuilder<HistoryTugasBloc, HistoryTugasState>(
        builder: (context, historyState) {
          if (authState is Authenticated && historyState is HistoryTugasInitial) {
            Future.microtask(() {
              context.read<HistoryTugasBloc>().add(
                  FetchHistoryTugasSiswa(token: authState.token, userId: authState.id, tugasId: widget.tugasId));
            });
          }

          // Handle loading state
          if (historyState is HistoryTugasLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (historyState is HistoryTugasError) {
            return Center(child: Text(historyState.message));
          }

          // Handle loaded state
          if (historyState is HistoryTugasLoaded) {
            final listHistory = historyState.histories;
            int counter = 0;

            if (listHistory.isEmpty) {
              return const Center(child: Text('Belum ada history pengumpulan tugas'));
            }

            return _buildHistoryList(context, listHistory, counter);
          }

          // Initial state
          return const Center(child: Text("Memuat data history tugas..."));
        },
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<HistoryTugasModel> listHistory, int counter) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: listHistory.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final history = listHistory[index];
        counter++;
        return _buildHistoryItem(context, history, counter);
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, HistoryTugasModel history, int counter) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bagian kiri: Nama pengumpulan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengumpulan ${counter++}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue, // Ganti dengan warna primary Anda
                    ),
                  ),
                ],
              ),
            ),

            // Bagian kanan: Tanggal pengumpulan
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(history.timestamps),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _formatTime(history.timestamps),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
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

  String _formatTime(DateTime date) {
    try {
      final formatter = DateFormat('HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return DateFormat('HH:mm').format(date); // Fallback format
    }
  }
}