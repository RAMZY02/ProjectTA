import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import '../../bloc/tahun_pelajaran/tahun_pelajaran_bloc.dart';
import '../../bloc/tahun_pelajaran/tahun_pelajaran_event.dart';
import '../../bloc/tahun_pelajaran/tahun_pelajaran_state.dart';
import '../../models/tahun_pelajaran_model.dart';

class TahunPelajaranScreen extends StatefulWidget {
  const TahunPelajaranScreen({super.key});

  @override
  _TahunPelajaranScreenState createState() => _TahunPelajaranScreenState();
}

class _TahunPelajaranScreenState extends State<TahunPelajaranScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if(authState is Authenticated){
      context.read<TahunPelajaranBloc>().add(FetchAllTahunPelajaran(token: authState.token));
    }
  }

  void _gantiTahunAjaran(TahunPelajaranModel currentTahunPelajaran, AuthState authState) {
    // Cek apakah semester saat ini adalah semester 2
    if (currentTahunPelajaran.semester != '2') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Tidak Dapat Mengganti Tahun Ajaran'),
            content: Text('Tahun ajaran hanya dapat diganti pada Semester 2. Saat ini masih Semester ${currentTahunPelajaran.semester}.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pergantian Tahun Ajaran'),
          content: Text('Apakah Anda yakin ingin mengganti tahun ajaran dari ${currentTahunPelajaran.tahun} Semester ${currentTahunPelajaran.semester} ke tahun ajaran berikutnya?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Buat tahun ajaran baru berdasarkan tahun ajaran saat ini
                List<String> parts = currentTahunPelajaran.tahun.split('/');
                int tahun1 = int.parse(parts[0]);
                int tahun2 = int.parse(parts[1]);

                String newTahunAjaran = '${tahun1 + 1}/${tahun2 + 1}';

                // Dispatch event untuk membuat tahun pelajaran baru
                if(authState is Authenticated){
                  context.read<TahunPelajaranBloc>().add(
                    CreateTahunPelajaran(
                      token: authState.token,
                      tahun: newTahunAjaran,
                      semester: '1',
                    ),
                  );
                }

                Navigator.of(context).pop();

                // Tampilkan snackbar konfirmasi
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tahun ajaran berhasil diganti menjadi $newTahunAjaran Semester 1'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Ya, Ganti'),
            ),
          ],
        );
      },
    );
  }

  void _gantiSemester(TahunPelajaranModel currentTahunPelajaran, AuthState authState) {
    if (currentTahunPelajaran.semester == '1') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pergantian Semester'),
            content: Text('Apakah Anda yakin ingin mengganti dari Semester 1 ke Semester 2?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  // Update semester menjadi 2
                  if(authState is Authenticated){
                    context.read<TahunPelajaranBloc>().add(
                      CreateTahunPelajaran(
                        token: authState.token,
                        tahun: currentTahunPelajaran.tahun,
                        semester: '2',
                      ),
                    );
                  }

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Berhasil pindah ke Semester 2'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text('Ya, Ganti'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pergantian Semester'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Semester 2 sudah berakhir. Silakan ganti tahun ajaran terlebih dahulu.'),
                SizedBox(height: 8),
                Text(
                  'Tips: Ganti tahun ajaran untuk memulai siklus baru dengan Semester 1.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Arahkan ke fungsi ganti tahun ajaran
                  _gantiTahunAjaran(currentTahunPelajaran, authState);
                },
                child: Text('Ganti Tahun Ajaran'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat data tahun pelajaran...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, AuthState authState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64),
          SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if(authState is Authenticated){
                context.read<TahunPelajaranBloc>().add(FetchAllTahunPelajaran(token: authState.token));
              }
            },
            child: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TahunPelajaranModel currentTahunPelajaran, AuthState authState) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Informasi Tahun Ajaran
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Tahun Pelajaran',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  currentTahunPelajaran.tahun,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: currentTahunPelajaran.semester == '1' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Semester ${currentTahunPelajaran.semester}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 48),

          // Tombol-tombol aksi
          Column(
            children: [
              // Tombol Pergantian Tahun Ajaran
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _gantiTahunAjaran(currentTahunPelajaran, authState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentTahunPelajaran.semester == '2' ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Pergantian Tahun Pelajaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Tombol Pergantian Semester
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _gantiSemester(currentTahunPelajaran, authState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentTahunPelajaran.semester == '1' ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Pergantian Semester',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 32),

          // Informasi status
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentTahunPelajaran.semester == '1'
                        ? 'Semester 1: Dapat melakukan pergantian semester'
                        : 'Semester 2: Silakan ganti tahun ajaran terlebih dahulu',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Tahun Ajaran'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<TahunPelajaranBloc, TahunPelajaranState>(
        listener: (context, state) {
          // Handle state changes yang membutuhkan action seperti show dialog/snackbar
          if (state is TahunPelajaranError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TahunPelajaranLoading) {
            return _buildLoadingState();
          } else if (state is TahunPelajaranError) {
            return _buildErrorState(state.message, authState);
          } else if (state is TahunPelajaranLoaded) {
            // Ambil tahun pelajaran aktif (biasanya yang terbaru)
            if (state.tahunPelajaranList.isEmpty) {
              return _buildErrorState('Tidak ada data tahun pelajaran', authState);
            }

            // Asumsikan tahun pelajaran terbaru adalah yang pertama dalam list
            // atau Anda bisa menambahkan logika untuk menentukan yang aktif
            final currentTahunPelajaran = state.tahunPelajaranList.last;

            return _buildContent(currentTahunPelajaran, authState);
          } else {
            return _buildLoadingState();
          }
        },
      ),
    );
  }
}