import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_bloc.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_event.dart';
import 'package:project_ta/bloc/penilaian_tugas/penilaian_tugas_bloc.dart';
import 'package:project_ta/bloc/penilaian_tugas/penilaian_tugas_event.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_bloc.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_event.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_state.dart';
import 'package:project_ta/bloc/users/users_state.dart';
import 'package:project_ta/models/laporan_tugas_model.dart';
import 'package:project_ta/models/nilai_akhir_siswa_model.dart';
import 'package:project_ta/models/user_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html; // Import untuk web
import 'package:path_provider/path_provider.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/kelas_mengajar/kelas_mengajar_state.dart';
import '../bloc/nilai_akhir_siswa/nilai_akhir_siswa_bloc.dart';
import '../bloc/nilai_akhir_siswa/nilai_akhir_siswa_event.dart';
import '../bloc/nilai_akhir_siswa/nilai_akhir_siswa_state.dart';
import '../bloc/penilaian_tugas/penilaian_tugas_state.dart';
import '../bloc/users/users_bloc.dart';
import '../bloc/users/users_event.dart';
import '../models/ujian_harian_model.dart';
import '../widgets/editable_student_grade_data_source.dart';

class LaporanNilaiScreen extends StatefulWidget {
  const LaporanNilaiScreen({super.key});

  @override
  State<LaporanNilaiScreen> createState() => _LaporanNilaiScreenState();
}

class _LaporanNilaiScreenState extends State<LaporanNilaiScreen> {
  String selectedClass = '';
  List<String> classes = [];
  int jumlahTugas = 0;
  List<String> tugasHeaders = [];
  List<NilaiAkhirSiswaModel> allCapaianKompetensi = <NilaiAkhirSiswaModel>[];
  int currentTahunPelajaran = 1;

  // Ubah menjadi Map yang menyimpan nilai per kelas
  Map<String, Map<int, Map<String, dynamic>>> nilaiTugasMapPerKelas = {};

  bool isLoadingClasses = true;

  // Tambahkan DataGridController yang tepat untuk SfDataGrid
  final DataGridController _dataGridController = DataGridController();

  @override
  void initState() {
    super.initState();
    _loadTugasSettings();

    // Delay sedikit inisialisasi untuk menghindari rebuild awal
    Future.delayed(Duration.zero, () {
      final authState = context.read<AuthBloc>().state;
      _loadKelasMengajar(authState, context);
    });
  }

  @override
  void dispose() {
    _dataGridController.dispose();
    super.dispose();
  }

  // Helper untuk mendapatkan nilaiTugasMap untuk kelas yang dipilih
  Map<int, Map<String, dynamic>> get nilaiTugasMap {
    return nilaiTugasMapPerKelas[selectedClass] ?? {};
  }

  // Helper untuk mengatur nilaiTugasMap untuk kelas yang dipilih
  set nilaiTugasMap(Map<int, Map<String, dynamic>> value) {
    nilaiTugasMapPerKelas[selectedClass] = value;
  }

  // Load settings dari SharedPreferences
  Future<void> _loadTugasSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJumlahTugas = prefs.getInt('jumlah_tugas') ?? 0;
      final savedTugasHeaders = prefs.getStringList('tugas_headers') ?? [];

      setState(() {
        jumlahTugas = savedJumlahTugas;
        tugasHeaders = savedTugasHeaders;
      });
    } catch (e) {
      print('Error loading tugas settings: $e');
    }
  }

  // Save settings ke SharedPreferences
  Future<void> _saveTugasSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('jumlah_tugas', jumlahTugas);
      await prefs.setStringList('tugas_headers', tugasHeaders);
    } catch (e) {
      print('Error saving tugas settings: $e');
    }
  }

  void _loadKelasMengajar(AuthState authState, BuildContext context) {
    if (authState is Authenticated) {
      context.read<KelasMengajarBloc>().add(
        FetchKelasMengajarByUserId(
          idUser: authState.id,
          token: authState.token,
        ),
      );
    }
  }

  void _loadStudentGrades(AuthState authState, BuildContext context) {
    if (authState is Authenticated && selectedClass.isNotEmpty) {
      context.read<UsersBloc>().add(
        LoadRapot(token: authState.token, kelas: selectedClass, id_mapel: authState.id_mapel),
      );
    }
  }

  void _loadCapaianKompetensi(AuthState authState, BuildContext context) {
    if (authState is Authenticated && selectedClass.isNotEmpty) {
      context.read<NilaiAkhirSiswaBloc>().add(
        FetchNilaiAkhirSiswaByMapelAndKelas(token: authState.token, kelas: selectedClass, id_mapel: authState.id_mapel),
      );
    }
  }

  void _loadTahunPelajaran(AuthState authState, BuildContext context) {
    if (authState is Authenticated && selectedClass.isNotEmpty) {
      context.read<TahunPelajaranBloc>().add(
        FetchAllTahunPelajaran(token: authState.token),
      );
    }
  }

  void _tambahKolomLatihan() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController(text: '1');
        return AlertDialog(
          title: const Text('Tambah Kolom Latihan'),
          content: DropdownButtonFormField<int>(
            value: controller.text.isNotEmpty ? int.tryParse(controller.text) : 1,
            decoration: const InputDecoration(
              labelText: 'Jumlah kolom latihan',
            ),
            items: List.generate(10, (index) => index + 1)
                .map((number) => DropdownMenuItem<int>(
              value: number,
              child: Text('$number'),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                controller.text = value.toString();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final input = controller.text;
                if (input.isNotEmpty) {
                  final jumlah = int.tryParse(input) ?? 0;
                  if (jumlah > 0) {
                    setState(() {
                      jumlahTugas = jumlah;
                      tugasHeaders = List.generate(jumlah, (index) => 'Latihan ${index + 1}');
                    });

                    // Simpan ke SharedPreferences
                    await _saveTugasSettings();

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Masukkan angka yang valid (> 0)')),
                    );
                  }
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mendapatkan semua ujian harian unik dari semua siswa
  List<UjianHarianModel> _getAllUjianHarian(List<UserModel> students) {
    final allUjianHarian = <UjianHarianModel>[];
    final seenIds = <int>{};

    for (final student in students) {
      if (student.ujianHarian != null) {
        for (final ujian in student.ujianHarian!) {
          if (!seenIds.contains(ujian.id)) {
            seenIds.add(ujian.id);
            allUjianHarian.add(ujian);
          }
        }
      }
    }

    allUjianHarian.sort((a, b) => a.id.compareTo(b.id));
    return allUjianHarian;
  }

  String _getNilaiUjianHarian(UserModel student, int ujianId) {
    if (student.ujianHarian == null) return '-';

    try {
      final ujian = student.ujianHarian!.firstWhere(
            (ujian) => ujian.id == ujianId,
      );
      return ujian.nilai.toString();
    } catch (e) {
      return '-';
    }
  }

  // Fungsi untuk mendapatkan semua ujian harian unik dari semua siswa
  List<LaporanTugasModel> _getAllLaporanTugas(List<UserModel> students) {
    final allLaporanTugas = <LaporanTugasModel>[];
    final seenIds = <int>{};

    for (final student in students) {
      if (student.laporanTugas != null) {
        for (final tugas in student.laporanTugas!) {
          if (!seenIds.contains(tugas.id)) {
            seenIds.add(tugas.id);
            allLaporanTugas.add(tugas);
          }
        }
      }
    }

    allLaporanTugas.sort((a, b) => a.id.compareTo(b.id));
    return allLaporanTugas;
  }

  String _getNilaiLaporanTugas(UserModel student, int tugasId) {
    if (student.laporanTugas == null) return '-';

    try {
      final tugas = student.laporanTugas!.firstWhere((tugas) => tugas.id == tugasId);
      return tugas.nilai.toString();
    } catch (e) {
      return '-';
    }
  }

  String _getCapaianKompetensi(UserModel student, int idMapel) {
    try {
      final capaian = allCapaianKompetensi.firstWhere((capaian) => capaian.idUser == student.id && capaian.id_mapel == idMapel);
      return capaian.capaian_kompetensi;
    } catch (e) {
      return '';
    }
  }

  // Fungsi untuk mendapatkan nilai tugas
  String _getNilaiTugas(UserModel student, int tugasIndex) {
    final studentNilai = nilaiTugasMap[student.id] ?? {};
    return studentNilai['Tugas ${tugasIndex+1}']?.toString() ?? '0';
  }

  // Update method untuk menghindari setState yang tidak perlu
  void _updateNilaiTugas(UserModel student, int tugasIndex, String nilai) {
    final state = context.read<AuthBloc>().state;
    nilaiTugasMap[student.id]!['Tugas ${tugasIndex + 1}'] = int.parse(nilai) ;
    if (state is Authenticated) {
      context.read<PenilaianTugasBloc>().add(CreatePenilaianTugas(
          idUser: student.id,
          nilai: int.parse(nilai),
          token: state.token,
          id_mapel: state.id_mapel,
          kolom: tugasIndex + 1,
          kelas: student.kelas
      ));
    }
  }

  void _createOrUpdateCapaian(UserModel student, String capaian) {
    final state = context.read<AuthBloc>().state;
    if(state is Authenticated){
      context.read<NilaiAkhirSiswaBloc>().add(CreateOrUpdateNilaiAkhirSiswa(
          token: state.token,
          idUser: student.id,
          id_mapel: state.id_mapel,
          kelas: selectedClass,
          nilaiAkhir: 0,
          capaian_kompetensi: capaian,
      ));
    }
  }

  int _hitungNilaiAkhir(UserModel student, List<UjianHarianModel> allUjianHarian, List<LaporanTugasModel> allLaporanTugas) {
    double totalNilai = 0;
    double totalNilai2 = 0;
    int count = 0;
    int count2 = 0;

    // Hitung rata-rata ujian harian
    if (student.ujianHarian != null && student.ujianHarian!.isNotEmpty) {
      for (final ujian in student.ujianHarian!) {
        totalNilai += ujian.nilai.toDouble();
        count++;
      }
    }

    // Hitung rata-rata nilai tugas
    if (student.laporanTugas != null && student.laporanTugas!.isNotEmpty) {
      for (final tugas in student.laporanTugas!) {
        totalNilai2 += tugas.nilai.toDouble();
        count2++;
      }
    }

    // Hitung rata-rata nilai latihan
    final studentNilai = nilaiTugasMap[student.id] ?? {};
    double totalTugas = 0;
    int countTugas = 0;

    for (int i = 0; i < jumlahTugas; i++) {
      final nilaiTugas = studentNilai['Tugas ${i + 1}'] ?? 0;
      totalTugas += nilaiTugas.toDouble();
      countTugas++;
    }
    final rataLatihan = countTugas > 0 ? totalTugas / countTugas : 0;
    final rataTugas = count2 > 0 ? totalNilai2 / count2 : 0;

    final rataUjianHarian = count > 0 ? totalNilai / count : 0;
    final uts = int.tryParse(student.uts) ?? 0;
    final uas = int.tryParse(student.uas) ?? 0;

    // Perhitungan: Tugas 30%, Ujian Harian 30%, UTS 20%, UAS 20%
    return (((rataTugas + rataLatihan) / 2 * 0.3) +
        (rataUjianHarian * 0.3) +
        (uts * 0.2) +
        (uas * 0.2)).round();
  }

  Future<void> _exportToExcel(AuthState authState, BuildContext context, List<UserModel> students) async {
    try {
      if (authState is! Authenticated) return;

      if (students.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data untuk diexport')),
        );
        return;
      }

      final allUjianHarian = _getAllUjianHarian(students);
      final allLaporanTugas = _getAllLaporanTugas(students);
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Headers
      final List<String> headers = ['No', 'Nama'];
      headers.addAll(tugasHeaders);

      for (final tugas in allLaporanTugas) {
        headers.add(tugas.nama);
      }

      for (final ujian in allUjianHarian) {
        headers.add(ujian.nama);
      }

      headers.addAll(['UTS', 'UAS', 'NA']);

      // Add headers
      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      }

      final Range headerRange = sheet.getRangeByIndex(1, 1, 1, headers.length);
      headerRange.cellStyle.bold = true;

      // Add data
      for (var i = 0; i < students.length; i++) {
        final student = students[i];
        int col = 1;

        sheet.getRangeByIndex(i + 2, col++).setNumber((i + 1).toDouble());
        sheet.getRangeByIndex(i + 2, col++).setText(student.nama);

        // Kolom Latihan
        final studentNilai = nilaiTugasMap[student.id] ?? {};
        for (int j = 0; j < jumlahTugas; j++) {
          final nilai = studentNilai['Tugas ${j + 1}'] ?? 0;
          sheet.getRangeByIndex(i + 2, col++).setNumber(nilai.toDouble());
        }

        // Kolom Tugas
        for (final tugas in allLaporanTugas) {
          final nilai = _getNilaiLaporanTugas(student, tugas.id);
          if (nilai == '-') {
            sheet.getRangeByIndex(i + 2, col++).setText('-');
          } else {
            sheet.getRangeByIndex(i + 2, col++).setNumber(double.parse(nilai));
          }
        }

        // Kolom ujian harian
        for (final ujian in allUjianHarian) {
          final nilai = _getNilaiUjianHarian(student, ujian.id);
          if (nilai == '-') {
            sheet.getRangeByIndex(i + 2, col++).setText('-');
          } else {
            sheet.getRangeByIndex(i + 2, col++).setNumber(double.parse(nilai));
          }
        }

        // UTS dan UAS
        final uts = student.uts == '-' ? 0 : int.tryParse(student.uts) ?? 0;
        final uas = student.uas == '-' ? 0 : int.tryParse(student.uas) ?? 0;
        sheet.getRangeByIndex(i + 2, col++).setNumber(uts.toDouble());
        sheet.getRangeByIndex(i + 2, col++).setNumber(uas.toDouble());

        // Nilai Akhir
        final na = _hitungNilaiAkhir(student, allUjianHarian, allLaporanTugas);
        sheet.getRangeByIndex(i + 2, col++).setNumber(na.toDouble());
      }

      // Auto-fit columns
      sheet.getRangeByName('A1:${String.fromCharCode(65 + headers.length - 1)}${students.length + 1}').autoFitColumns();

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      if (kIsWeb) {
        // Export untuk Web - Method yang lebih aman
        await _exportForWeb(bytes, authState.mapel, selectedClass, context);
      } else {
        // Export untuk Android
        await _exportForMobile(bytes, authState.mapel, selectedClass, context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e')),
        );
      }
    }
  }

  Future<void> _exportForWeb(List<int> bytes, String mapel, String selectedClass, BuildContext context) async {
    try {
      final fileName = 'Laporan Nilai_${mapel}_Kelas_$selectedClass.xlsx';

      // Method 1: Menggunakan Blob (modern approach)
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.document.createElement('a') as html.AnchorElement;
      anchor.href = url;
      anchor.download = fileName;
      anchor.style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);

      html.Url.revokeObjectUrl(url);

      // Tampilkan snackbar success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diexport, file akan terdownload'),
          ),
        );
      }
    } catch (e) {
      // Fallback method
      _fallbackExportForWeb(bytes, mapel, selectedClass, context);
    }
  }

  void _fallbackExportForWeb(List<int> bytes, String mapel, String selectedClass, BuildContext context) {
    try {
      final fileName = 'Laporan Nilai_${mapel}_Kelas_$selectedClass.xlsx';

      // Method alternatif: menggunakan base64
      final base64 = base64Encode(bytes);
      final uri = 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$base64';

      final anchor = html.document.createElement('a') as html.AnchorElement;
      anchor.href = uri;
      anchor.download = fileName;
      anchor.style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diexport menggunakan metode alternatif'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export di web: $e')),
        );
      }
    }
  }

  Future<void> _exportForMobile(List<int> bytes, String mapel, String selectedClass, BuildContext context) async {
    try {
      final String path;
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        path = '${directory.path}/Laporan Nilai_${mapel}_Kelas_$selectedClass.xlsx';
      } else {
        path = '/storage/emulated/0/Download/Laporan Nilai_${mapel}_Kelas_$selectedClass.xlsx';
      }

      final File file = File(path);
      await file.writeAsBytes(bytes);
      await OpenFile.open(path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diexport ke Download'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export di mobile: $e')),
        );
      }
    }
  }

  void _submitAllNilaiAkhir(AuthState authState, BuildContext context, List<UserModel> students, List<UjianHarianModel> allUjianHarian, List<LaporanTugasModel> allLaporanTugas) {
    if (authState is! Authenticated) return;

    // Siapkan data nilai akhir untuk semua siswa
    final nilaiAkhirList = students.map((student) {
      final nilaiAkhir = _hitungNilaiAkhir(student, allUjianHarian, allLaporanTugas);
      return {
        'id_user': student.id,
        'id_mapel': authState.id_mapel,
        'kelas': student.kelas,
        'nilai_akhir': nilaiAkhir,
        'capaian_kompetensi' : ''
      };
    }).toList();

    // Panggil event untuk create semua nilai akhir
    context.read<NilaiAkhirSiswaBloc>().add(
      CreateAllNilaiAkhirSiswa(
        nilaiAkhirList: nilaiAkhirList,
        token: authState.token,
      ),
    );
  }

  final GlobalKey<SfDataGridState> _dataGridKey = GlobalKey<SfDataGridState>();

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return MultiBlocListener(
      listeners: [
        BlocListener<PenilaianTugasBloc, PenilaianTugasState>(
          listener: (context, state) {
            if (state is PenilaianTugasCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Nilai berhasil diperbarui')),
              );
            }
          },
        ),
        BlocListener<KelasMengajarBloc, KelasMengajarState>(
          listener: (context, state) {
            if (state is KelasMengajarByUserIdLoaded) {
              final kelasList = state.kelasMengajarList.map((e) => e.kelas).toList();
              setState(() {
                classes = kelasList;
                isLoadingClasses = false;
                if (selectedClass.isEmpty && classes.isNotEmpty) {
                  selectedClass = classes.first;
                  _loadStudentGrades(authState, context);
                  _loadCapaianKompetensi(authState, context);
                  _loadTahunPelajaran(authState, context);
                }
              });
            } else if (state is KelasMengajarError) {
              setState(() {
                isLoadingClasses = false;
                classes = [];
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat kelas: ${state.message}')),
              );
            }
          },
        ),
        BlocListener<NilaiAkhirSiswaBloc, NilaiAkhirSiswaState>(
          listener: (context, state) {
            if(state is NilaiAkhirSiswaLoaded){
              setState(() {
                allCapaianKompetensi = state.nilaiAkhirList;
              });
            }
            if (state is NilaiAkhirSiswaSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.data.toString())),
              );
            } else if (state is NilaiAkhirSiswaError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
        BlocListener<TahunPelajaranBloc, TahunPelajaranState>(
          listener: (context, state) {
            if (state is TahunPelajaranLoaded) {
              currentTahunPelajaran = state.tahunPelajaranList.last.id;
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: authState is Authenticated ? Text('Laporan Nilai ${authState.mapel}') : Text('Laporan Nilai'),
          actions: [
            if (classes.isNotEmpty) // Hanya tampilkan tombol tambah jika ada kelas
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _tambahKolomLatihan,
                tooltip: 'Tambah Kolom Latihan',
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Tampilkan loading atau daftar kelas
              if (isLoadingClasses)
                const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (classes.isEmpty)
                const SizedBox(
                  height: 60,
                  child: Center(child: Text('Tidak ada kelas yang diajar')),
                )
              else
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final className = classes[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ChoiceChip(
                          label: Text(className),
                          selected: selectedClass == className,
                          onSelected: (selected) {
                            setState(() {
                              selectedClass = className;
                              _loadStudentGrades(authState, context);
                              _loadCapaianKompetensi(authState, context);
                              _loadTahunPelajaran(authState, context);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

              // Tampilkan tabel hanya jika ada kelas yang dipilih dan kelas tersedia
              if (classes.isNotEmpty && selectedClass.isNotEmpty)
                BlocBuilder<UsersBloc, UsersState>(
                  builder: (context, usersState) {
                    if (usersState is UsersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (usersState is UsersError) {
                      return Text("Error: ${usersState.message}");
                    }

                    if (usersState is UsersLoaded) {
                      // Inisialisasi data tugas untuk kelas ini
                      if (!nilaiTugasMapPerKelas.containsKey(selectedClass)) {
                        // Inisialisasi baru untuk kelas ini
                        final newMap = <int, Map<String, dynamic>>{};

                        for (final user in usersState.users) {
                          newMap[user.id] = {};

                          // Isi dengan data penilaian tugas yang sudah ada
                          if (user.penilaianTugas != null) {
                            for (final penilaian in user.penilaianTugas!) {
                              newMap[user.id]!['Tugas ${penilaian.kolom}'] = penilaian.nilai;
                            }
                          }
                        }

                        nilaiTugasMapPerKelas[selectedClass] = newMap;
                      }

                      final allUjianHarian = _getAllUjianHarian(usersState.users);
                      final allLaporanTugas = _getAllLaporanTugas(usersState.users);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SfDataGrid(
                            key: _dataGridKey,
                            controller: _dataGridController, // Gunakan DataGridController yang benar
                            source: EditableStudentGradeDataSource(
                              idMapel: authState is Authenticated ? authState.id_mapel : 0,
                              students: usersState.users,
                              jumlahTugas: jumlahTugas,
                              id_tahun_pelajaran: currentTahunPelajaran,
                              tugasHeaders: tugasHeaders,
                              allUjianHarian: allUjianHarian,
                              allLaporanTugas: allLaporanTugas,
                              allCapaianKompetensi: allCapaianKompetensi,
                              getNilaiUjianHarian: _getNilaiUjianHarian,
                              getNilaiLaporanTugas: _getNilaiLaporanTugas,
                              getNilaiTugas: _getNilaiTugas,
                              getCapaianKompetensi: _getCapaianKompetensi,
                              hitungNilaiAkhir: (student) => _hitungNilaiAkhir(student, allUjianHarian, allLaporanTugas),
                              onNilaiTugasChanged: _updateNilaiTugas,
                              onCapaianChanged: _createOrUpdateCapaian,
                            ),
                            columns: _buildColumns(allUjianHarian, allLaporanTugas),
                            selectionMode: SelectionMode.single,
                            navigationMode: GridNavigationMode.cell,

                            // Konfigurasi untuk drag dan scroll
                            isScrollbarAlwaysShown: true,
                            horizontalScrollPhysics: const BouncingScrollPhysics(),
                            verticalScrollPhysics: const BouncingScrollPhysics(),

                            // Konfigurasi tampilan
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            columnWidthMode: ColumnWidthMode.auto,
                            rowHeight: 100,
                            headerRowHeight: 50,

                            // Enable interaction
                            allowSorting: true,
                            allowFiltering: false,
                            allowColumnsResizing: true,
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink(); // Jangan tampilkan apa-apa jika tidak ada data
                  },
                )
              else if (classes.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Tidak ada kelas yang diajar. Silakan hubungi administrator untuk ditugaskan ke kelas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Tombol Export Excel
            BlocBuilder<UsersBloc, UsersState>(
              builder: (context, usersState) {
                if (classes.isNotEmpty && selectedClass.isNotEmpty && usersState is UsersLoaded) {
                  return FloatingActionButton(
                    onPressed: () {
                      _exportToExcel(authState, context, usersState.users);
                    },
                    tooltip: 'Export to Excel',
                    heroTag: 'export_btn', // Tambahkan heroTag unik
                    child: const Icon(Icons.download),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 16),
            // Tombol Submit Nilai Akhir
            BlocBuilder<UsersBloc, UsersState>(
              builder: (context, usersState) {
                if (classes.isNotEmpty && selectedClass.isNotEmpty && usersState is UsersLoaded) {
                  return FloatingActionButton(
                    onPressed: () {
                      final allUjianHarian = _getAllUjianHarian(usersState.users);
                      final allLaporanTugas = _getAllLaporanTugas(usersState.users);
                      _submitAllNilaiAkhir(authState, context, usersState.users, allUjianHarian, allLaporanTugas);
                    },
                    tooltip: 'Submit Nilai Akhir',
                    backgroundColor: Colors.green, // Warna berbeda untuk membedakan
                    heroTag: 'submit_btn', // Tambahkan heroTag unik
                    child: const Icon(Icons.save),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  List<GridColumn> _buildColumns(List<UjianHarianModel> allUjianHarian, List<LaporanTugasModel> allLaporanTugas) {
    final List<GridColumn> columns = [
      GridColumn(
        columnName: 'No',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('No'),
        ),
      ),
      GridColumn(
        columnName: 'Nama',
        width: 210,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Nama'),
        ),
      ),
    ];

    // Kolom latihan dinamis (editable)
    for (int i = 0; i < jumlahTugas; i++) {
      columns.add(
        GridColumn(
          columnName: 'Latihan ${i + 1}',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(tugasHeaders.isNotEmpty && i < tugasHeaders.length
                ? tugasHeaders[i]
                : 'Latihan ${i + 1}'),
          ),
        ),
      );
    }

    // Kolom tugas dinamis
    int counter2 = 0;
    for (final tugas in allLaporanTugas) {
      columns.add(
        GridColumn(
          columnName: 'Tugas ${++counter2}',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text('Tugas $counter2'),
          ),
        ),
      );
    }

    // Kolom ujian harian dinamis
    int counter = 0;
    for (final ujian in allUjianHarian) {
      columns.add(
        GridColumn(
          columnName: 'UH ${++counter}',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text('UH $counter'),
          ),
        ),
      );
    }

    // Kolom tetap lainnya
    columns.addAll([
      GridColumn(
        columnName: 'UTS',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('UTS'),
        ),
      ),
      GridColumn(
        columnName: 'UAS',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('UAS'),
        ),
      ),
      GridColumn(
        columnName: 'NA',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('NA'),
        ),
      ),
      GridColumn(
        columnName: 'Capaian Kompetensi',
        width: 300,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Capaian Kompetensi'),
        ),
      ),
    ]);

    return columns;
  }
}