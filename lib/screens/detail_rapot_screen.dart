import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/nilai_akhir_siswa/nilai_akhir_siswa_bloc.dart';
import 'package:project_ta/bloc/nilai_akhir_siswa/nilai_akhir_siswa_state.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_bloc.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_event.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_state.dart';
import 'package:project_ta/models/nilai_akhir_siswa_model.dart';
import 'package:project_ta/models/user_model.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../bloc/nilai_akhir_siswa/nilai_akhir_siswa_event.dart';

class DetailRapotScreen extends StatefulWidget {
  final UserModel student;

  const DetailRapotScreen({super.key, required this.student});

  @override
  State<DetailRapotScreen> createState() => _DetailRapotScreenState();
}

class _DetailRapotScreenState extends State<DetailRapotScreen> {
  List<NilaiAkhirSiswaModel> nilaiAkhirList = [];
  String tahunAjar = '';
  String semester = '';
  TextEditingController catatanWaliKelasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNilaiAkhirSiswa();
    _loadTahunPelajaran();
    // Set nilai default untuk catatan wali kelas
    catatanWaliKelasController.text = '';
  }

  @override
  void dispose() {
    catatanWaliKelasController.dispose();
    super.dispose();
  }

  void _loadNilaiAkhirSiswa() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<NilaiAkhirSiswaBloc>().add(FetchAllNilaiAkhirSiswa(
          token: authState.token));
    }
  }

  void _loadTahunPelajaran() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<TahunPelajaranBloc>().add(FetchAllTahunPelajaran(token: authState.token));
    }
  }

  // Fungsi untuk format tanggal dalam bahasa Indonesia
  String _formatTanggalIndonesia(DateTime date) {
    final List<String> namaBulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return 'Mataram, ${date.day} ${namaBulan[date.month - 1]} ${date.year}';
  }

  Future<void> _cetakPDF() async {
    try {
      if (nilaiAkhirList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data nilai untuk dicetak')),
        );
        return;
      }

      // Tunggu sampai data tahun pelajaran tersedia
      if (tahunAjar.isEmpty || semester.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sedang memuat data tahun pelajaran...')),
        );
        return;
      }

      final pdf = pw.Document();
      final DateTime sekarang = DateTime.now();
      final String tanggalSekarang = _formatTanggalIndonesia(sekarang);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header Informasi Siswa dan Sekolah
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Informasi Siswa
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Nama : ${widget.student.nama.toUpperCase()}'),
                      pw.Text('NIS/NISN : ${widget.student.nis} / ${widget.student.nisn}'),
                      pw.Text('Nama Sekolah : SMP NEGERI 2 MATARAM'),
                      pw.Text('Alamat : JL Pejanggik No. 5 Mataram'),
                    ],
                  ),

                  // Informasi Kelas
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Kelas : ${widget.student.kelas}'),
                      pw.Text('Fase : D'),
                      pw.Text('Semester : $semester'),
                      pw.Text('Tahun Pelajaran : $tahunAjar'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(height: 1),
              pw.SizedBox(height: 20),

              // Judul LAPORAN HASIL BELAJAR
              pw.Center(
                child: pw.Text(
                  'LAPORAN HASIL BELAJAR',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              // Tabel Nilai Akademik
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(),
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerLeft,
                },
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FixedColumnWidth(150),
                  2: const pw.FixedColumnWidth(60),
                  3: const pw.FlexColumnWidth(),
                },
                headers: ['No', 'Mata Pelajaran', 'Nilai Akhir', 'Capaian Kompetensi'],
                data: List<List<dynamic>>.generate(
                  nilaiAkhirList.length,
                      (i) => [
                    '${i + 1}',
                    nilaiAkhirList[i].mapel,
                    nilaiAkhirList[i].nilai_akhir.toString(),
                    nilaiAkhirList[i].capaian_kompetensi,
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Catatan Wali Kelas
              pw.Text('Catatan Wali Kelas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(
                catatanWaliKelasController.text != ''
                    ? catatanWaliKelasController.text
                    : 'Ananda sudah menunjukkan sikap dan perilaku yang baik dalam belajar serta dapat bekerja sama dengan temannya. Teruslah mengembangkan sikap dan perilaku yang positif dalam keseharian, baik di lingkungan sekolah maupun di lingkungan keluarga.',
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
              ),

              // Footer dengan tanda tangan
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 20),
                child: pw.Column(
                  children: [
                    // Baris pertama untuk Wali Kelas dan Orang Tua
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        // Tanda Tangan Wali Kelas (kiri)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(tanggalSekarang), // Menggunakan tanggal sekarang
                            pw.SizedBox(height: 40),
                            pw.Text('Wali Kelas'),
                            pw.SizedBox(height: 80),
                            pw.Text('(__________________________)'),
                          ],
                        ),

                        // Tanda Tangan Orang Tua/Wali (kanan)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(height: 55),
                            pw.Text('Orang Tua/Wali'),
                            pw.SizedBox(height: 80),
                            pw.Text('(__________________________)'),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 80),

                    // Baris kedua untuk Kepala Sekolah di tengah
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Text('Kepala Sekolah'),
                          pw.SizedBox(height: 80),
                          pw.Text('(__________________________)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Cetak atau simpan PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencetak: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rapot - ${widget.student.nama}'),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          // Listener untuk Nilai Akhir Siswa
          BlocListener<NilaiAkhirSiswaBloc, NilaiAkhirSiswaState>(
            listener: (context, state) {
              if (state is NilaiAkhirSiswaLoaded) {
                setState(() {
                  nilaiAkhirList = state.nilaiAkhirList
                      .where((nilai) => nilai.idUser == widget.student.id)
                      .toList();
                });
              }
            },
          ),
          // Listener untuk Tahun Pelajaran
          BlocListener<TahunPelajaranBloc, TahunPelajaranState>(
            listener: (context, state) {
              if (state is TahunPelajaranLoaded) {
                if (state.tahunPelajaranList.isNotEmpty) {
                  final tahunPelajaran = state.tahunPelajaranList.last;
                  setState(() {
                    tahunAjar = tahunPelajaran.tahun;
                    semester = tahunPelajaran.semester;
                  });
                }
              } else if (state is TahunPelajaranError) {
                // Fallback values jika terjadi error
                setState(() {
                  tahunAjar = '2024/2025';
                  semester = 'Ganjil';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal memuat tahun pelajaran: ${state.message}')),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<NilaiAkhirSiswaBloc, NilaiAkhirSiswaState>(
          builder: (context, state) {
            if (state is NilaiAkhirSiswaLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NilaiAkhirSiswaError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            if (nilaiAkhirList.isEmpty) {
              return const Center(child: Text("Belum ada data nilai"));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi Tahun Pelajaran
                  BlocBuilder<TahunPelajaranBloc, TahunPelajaranState>(
                    builder: (context, state) {
                      if (state is TahunPelajaranLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tahun Pelajaran: $tahunAjar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Semester: $semester',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // TextField untuk Catatan Wali Kelas
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan Wali Kelas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: catatanWaliKelasController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Masukkan catatan untuk wali kelas...',
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.all(12.0),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Catatan ini akan muncul di PDF yang dicetak',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tabel Nilai
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('No')),
                          DataColumn(label: Text('Mata Pelajaran')),
                          DataColumn(label: Text('Nilai Akhir')),
                          DataColumn(
                            label: Text('Capaian Kompetensi'),
                          ),
                        ],
                        rows: nilaiAkhirList.map((nilai) {
                          return DataRow(cells: [
                            DataCell(Text('${nilaiAkhirList.indexOf(nilai) + 1}')),
                            DataCell(Text(nilai.mapel)),
                            DataCell(Center(child: Text(nilai.nilai_akhir.toString()))),
                            DataCell(
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  nilai.capaian_kompetensi,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cetakPDF,
        tooltip: 'Cetak PDF',
        child: const Icon(Icons.print),
      ),
    );
  }
}