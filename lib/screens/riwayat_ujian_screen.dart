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

class RiwayatUjianScreen extends StatefulWidget {
  const RiwayatUjianScreen({super.key});

  @override
  State<RiwayatUjianScreen> createState() => _RiwayatUjianScreenState();
}

class _RiwayatUjianScreenState extends State<RiwayatUjianScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<HistoryUjianModel> _filteredHistories = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _filterHistories(List<HistoryUjianModel> histories) {
    if (_searchQuery.isEmpty) {
      _filteredHistories = List.from(histories);
    } else {
      _filteredHistories = histories.where((history) {
        final mapel = history.ujian.mapel.toLowerCase();
        final tipeUjian = history.ujian.tipe_ujian.toLowerCase();
        final tipeSoal = history.ujian.tipe_soal.toLowerCase();
        final tanggal = DateFormat('dd MMMM yyyy').format(history.ujian.tanggal).toLowerCase();
        final nilai = history.nilai.toString();

        return mapel.contains(_searchQuery) ||
            tipeUjian.contains(_searchQuery) ||
            tipeSoal.contains(_searchQuery) ||
            tanggal.contains(_searchQuery) ||
            nilai.contains(_searchQuery);
      }).toList();
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

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
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.grey,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari riwayat ujian...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(
                      Icons.search,
                      color: kPrimaryColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: _clearSearch,
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),

            // List Riwayat Ujian
            Expanded(
              child: BlocBuilder<HistoryUjianBloc, HistoryUjianState>(
                  builder: (context, historyUjianState) {
                    if (authState is Authenticated && historyUjianState is HistoryUjianInitial) {
                      context.read<HistoryUjianBloc>().add(FetchHistoryUjian(token: authState.token, userId: authState.id));
                    }

                    if (historyUjianState is HistoryUjianLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (historyUjianState is HistoryUjianLoaded) {
                      final histories = historyUjianState.histories;
                      _filterHistories(histories);

                      if (_filteredHistories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isEmpty
                                    ? Icons.history
                                    : Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? "Belum ada riwayat ujian"
                                    : "Riwayat tidak ditemukan",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isEmpty
                                    ? "Riwayat ujian akan muncul di sini"
                                    : "Coba kata kunci lain",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          if (authState is Authenticated) {
                            context.read<HistoryUjianBloc>().add(FetchHistoryUjian(token: authState.token, userId: authState.id));
                          }
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          itemCount: _filteredHistories.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final exam = _filteredHistories[index];
                            return _buildExamCard(context, exam);
                          },
                        ),
                      );
                    }

                    if (historyUjianState is HistoryUjianError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Terjadi Kesalahan",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                historyUjianState.message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (authState is Authenticated) {
                                  context.read<HistoryUjianBloc>().add(FetchHistoryUjian(token: authState.token, userId: authState.id));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Coba Lagi",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const Center(child: CircularProgressIndicator());
                  }
              ),
            ),
          ],
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
          if (exam.diperiksa == 'true') {
            context.read<SoalUjianBloc>().add(InitSoalUjian());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailRiwayatUjianScreen(exam: exam),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ujian Belum Diperiksa')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      exam.ujian.mapel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
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