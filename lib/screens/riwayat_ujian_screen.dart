import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_state.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/constants/color.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/models/history_ujian_model.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/history_ujian/history_ujian_bloc.dart';
import '../bloc/history_ujian/history_ujian_event.dart';
import 'detail_riwayat_ujian_screen.dart';

class RiwayatUjianScreen extends StatelessWidget {
  const RiwayatUjianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Ujian',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold
          )
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: BlocBuilder<HistoryUjianBloc, HistoryUjianState>(
          builder: (context, historyUjianState){
            if(authState is Authenticated && historyUjianState is HistoryUjianInitial){
              context.read<HistoryUjianBloc>().add(FetchHistoryUjian(token: authState.token, userId: authState.id));
            }
            if(historyUjianState is HistoryUjianLoaded){
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: historyUjianState.histories.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exam = historyUjianState.histories[index];
                  return _buildExamCard(context, exam);
                },
              );
            }
            else{
              return Center(child: CircularProgressIndicator());
            }
          }
      )
    );
  }

  Widget _buildExamCard(BuildContext context, HistoryUjianModel exam) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<SoalUjianBloc>().add(InitSoalUjian());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailRiwayatUjianScreen(exam: exam),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exam.ujian.mapel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(exam.nilai),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${exam.nilai}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                exam.ujian.tipe_ujian,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Jenis Soal: ${exam.ujian.tipe_soal}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Tanggal: ${DateFormat('dd MMMM yyyy').format(exam.ujian.tanggal)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: exam.nilai / 100,
                backgroundColor: Colors.grey[200],
                color: _getScoreColor(exam.nilai),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    return Colors.red;
  }
}