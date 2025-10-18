import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/screens/pengumpulan_tugas_screen.dart';
import '../bloc/tugas/tugas_bloc.dart';
import '../bloc/tugas/tugas_event.dart';
import '../bloc/tugas/tugas_state.dart';
import '../bloc/users/users_bloc.dart';
import '../bloc/users/users_event.dart';
import '../models/tugas_model.dart';
import 'tugas_form_screen.dart';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});

  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<TugasModel> _filteredTugasList = [];
  bool _isSearching = false;

  // Fungsi untuk memfilter tugas berdasarkan pencarian
  void _filterTugasList(String query, List<TugasModel> originalList) {
    if (query.isEmpty) {
      setState(() {
        _filteredTugasList = originalList;
        _isSearching = false;
      });
      return;
    }

    final filtered = originalList.where((tugas) {
      final nama = tugas.nama.toLowerCase();
      final deskripsi = tugas.deskripsi.toLowerCase();
      final deadline = _formatDate(tugas.deadline).toLowerCase();
      final searchLower = query.toLowerCase();

      return nama.contains(searchLower) ||
          deskripsi.contains(searchLower) ||
          deadline.contains(searchLower);
    }).toList();

    setState(() {
      _filteredTugasList = filtered;
      _isSearching = true;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredTugasList = [];
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return Scaffold(
        body: Center(
          child: Text(
            "Silakan Login Terlebih Dahulu",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    } else {
      return BlocBuilder<TugasBloc, TugasState>(
        builder: (context, state) {
          // Initialize data fetching if needed
          if (state is TugasInitial) {
            context.read<TugasBloc>().add(FetchTugasByIdUser(token: authState.token, id_user: authState.id));
          }

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                "Daftar Tugas",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              backgroundColor: kPrimaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.grey,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade50,
                    Colors.grey.shade100,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Search Bar - Disesuaikan dengan SoalScreen
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari tugas...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: _clearSearch,
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kPrimaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        if (state is TugasLoaded) {
                          _filterTugasList(value, state.tugas);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: BlocConsumer<TugasBloc, TugasState>(
                      listener: (context, state) {
                        if (state is TugasError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        if (state is TugasOperationSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          // Reload data after successful operation
                          context.read<TugasBloc>().add(FetchTugasByIdUser(token: authState.token, id_user: authState.id));
                        }
                      },
                      builder: (context, state) {
                        // Tampilkan hasil pencarian jika sedang searching
                        if (_isSearching) {
                          if (_filteredTugasList.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Tidak ada tugas yang ditemukan',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }
                          return _buildTugasList(_filteredTugasList, authState);
                        }

                        if (state is TugasLoading) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Memuat tugas...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is TugasLoaded) {
                          final tugasList = state.tugas;
                          if (tugasList.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada tugas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tekan + untuk membuat tugas baru',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return _buildTugasList(tugasList, authState);
                        } else if (state is TugasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Terjadi Kesalahan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              'Memuat...',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToCreateForm(
                  context, authState.token, authState.id),
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          );
        },
      );
    }
  }

  Widget _buildTugasList(List<TugasModel> tugasList, AuthState authState) {
    if(authState is! Authenticated) return Center(child: Text("Login Dulu Bang!"));
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: tugasList.length,
      itemBuilder: (context, index) {
        final tugas = tugasList[index];
        final isDeadlineNear = tugas.deadline
            .difference(DateTime.now())
            .inDays <= 3;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _navigateToSiswaList(
                  context, tugas, authState.token),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tugas.nama,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.blue.shade800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, size: 20),
                              color: Colors.blue.shade600,
                              onPressed: () => _navigateToEditForm(
                                context,
                                tugas,
                                authState.token,
                                authState.id,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, size: 20),
                              color: Colors.red.shade600,
                              onPressed: () => _confirmDelete(
                                context,
                                tugas,
                                authState.token,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: 1, color: Color(0xFFE2E8F0)),
                    SizedBox(height: 8),
                    Text(
                      tugas.deskripsi,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 6),
                    Divider(height: 1, color: Color(0xFFE2E8F0)),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.black,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Deadline: ${_formatDate(tugas.deadline)}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2,'0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _navigateToCreateForm(BuildContext context, String token, int userId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TugasFormScreen(token: token, userId: userId),
      ),
    );
  }

  void _navigateToEditForm(BuildContext context, TugasModel tugas, String token, int userId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TugasFormScreen(token: token, userId: userId, tugas: tugas),
      ),
    );
  }

  void _navigateToSiswaList(
      BuildContext context, TugasModel tugas, String token) {
    context.read<UsersBloc>().add(Init());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PengumpulanTugasScreen(tugas: tugas, token: token),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, TugasModel tugas, String token) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(
              'Hapus Tugas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus "${tugas.nama}"?',
              style: TextStyle(fontSize: 16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<TugasBloc>().add(
                      DeleteTugas(token: token, tugasId: tugas.id));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Hapus'),
              ),
            ],
          ),
    );
  }
}