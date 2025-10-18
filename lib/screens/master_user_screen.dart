import 'dart:ui';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/users/users_bloc.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/mata_pelajaran/mata_pelajaran_bloc.dart';
import '../bloc/mata_pelajaran/mata_pelajaran_event.dart';
import '../bloc/mata_pelajaran/mata_pelajaran_state.dart';
import '../bloc/users/users_state.dart';
import '../models/mata_pelajaran_model.dart';
import 'insert_user_screen.dart';

class MasterUserScreen extends StatefulWidget {
  const MasterUserScreen({super.key});

  @override
  State<MasterUserScreen> createState() => _MasterUserScreenState();
}

class _MasterUserScreenState extends State<MasterUserScreen> {
  // Tambahkan ScrollController untuk Scrollbar
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(authState is Authenticated){
            _importUsersFromExcel(authState.token);
          }
        },
        tooltip: 'Import Users from Excel',
        child: const Icon(Icons.upload_file),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Download Template Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Template'),
                    onPressed: _downloadExcelTemplate,
                  ),
                ),
                // Add Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('User'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InsertUserScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // DataTable - HAPUS Expanded yang berlebihan
            BlocConsumer<UsersBloc, UsersState>(
              listener: (context, usersState){
                if(usersState is UsersError){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(usersState.message)),
                  );
                  if(authState is Authenticated){
                    context
                        .read<UsersBloc>()
                        .add(FetchUsers(token: authState.token));
                  }
                }
              },
              builder: (context, usersState) {
                if (authState is! Authenticated) {
                  return Expanded(child: Center(child: Text("Login Dulu min")));
                }
                if (usersState is UsersInitial) {
                  context
                      .read<UsersBloc>()
                      .add(FetchUsers(token: authState.token));
                }
                if (usersState is UsersLoaded) {
                  if (usersState.users.isEmpty) {
                    return Expanded(child: Center(child: Text("Belum ada data tersedia")));
                  }

                  // GUNAKAN HANYA SATU Expanded di sini
                  return Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        },
                      ),
                      child: Scrollbar(
                        controller: _verticalController, // Tambahkan controller
                        thumbVisibility: true,
                        child: Scrollbar(
                          controller: _horizontalController, // Tambahkan controller
                          thumbVisibility: true,
                          notificationPredicate: (notif) => notif.depth == 1,
                          child: SingleChildScrollView(
                            controller: _verticalController,
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              controller: _horizontalController,
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 20,
                                horizontalMargin: 12,
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Nama')),
                                  DataColumn(label: Text('NIS')),
                                  DataColumn(label: Text('NISN')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Role')),
                                  DataColumn(label: Text('Nomor Ortu')),
                                  DataColumn(label: Text('Kelas')),
                                  DataColumn(label: Text('Agama')),
                                  DataColumn(label: Text('Mata Pelajaran')),
                                  DataColumn(label: Text('Wali Kelas')),
                                  DataColumn(label: Text('Poin')),
                                  DataColumn(label: Text('Profil Picture')),
                                  DataColumn(
                                    label: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text('Actions'),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: usersState.users.map((user) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(user.id.toString())),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 120),
                                          child: Text(
                                            user.nama,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(user.nis)),
                                      DataCell(Text(user.nisn)),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 150),
                                          child: Text(
                                            user.email,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(user.role)),
                                      DataCell(Text(user.nomor_ortu)),
                                      DataCell(Center(child: Text(user.kelas))),
                                      DataCell(Text(user.agama)),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 120),
                                          child: Text(
                                            user.mapel,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      DataCell(Center(child: Text(user.wali_kelas))),
                                      DataCell(Text(user.poin.toString())),
                                      DataCell(
                                          Center(
                                            child: user.profpic != '-' ?
                                            Image.network(
                                              user.profpic,
                                              width: 40,
                                              height: 40,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(Icons.error);
                                              },
                                            )
                                                : const Icon(Icons.person, size: 40),
                                          )
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
                                                    builder: (context) => InsertUserScreen(isEdit: true, userData: user),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                _deleteUser(authState.token, user.id);
                                              },
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
                        ),
                      ),
                    ),
                  );
                }
                else {
                  return Expanded(child: Center(child: CircularProgressIndicator()));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUser(String token, int id) {
    context.read<UsersBloc>().add(DeleteUsers(token: token, id_user: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User deleted successfully')),
    );
  }

  Future<void> _downloadExcelTemplate() async {
    try {
      final authState = context.read<AuthBloc>().state;

      if (authState is! Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan login terlebih dahulu')),
        );
        return;
      }

      // Fetch data mata pelajaran dari database
      List<MataPelajaranModel> mataPelajaranList = [];

      // Panggil event untuk fetch mata pelajaran
      context.read<MataPelajaranBloc>().add(FetchAllMataPelajaran(token: authState.token));

      // Tunggu sebentar untuk mendapatkan data (bisa disesuaikan dengan kebutuhan)
      await Future.delayed(const Duration(milliseconds: 500));

      // Create Excel workbook and sheet
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Add headers sesuai struktur tabel
      sheetObject.cell(CellIndex.indexByString('A1')).value = TextCellValue('Nama');
      sheetObject.cell(CellIndex.indexByString('B1')).value = TextCellValue('NIS');
      sheetObject.cell(CellIndex.indexByString('C1')).value = TextCellValue('NISN');
      sheetObject.cell(CellIndex.indexByString('D1')).value = TextCellValue('Email');
      sheetObject.cell(CellIndex.indexByString('E1')).value = TextCellValue('Password');
      sheetObject.cell(CellIndex.indexByString('F1')).value = TextCellValue('Role');
      sheetObject.cell(CellIndex.indexByString('G1')).value = TextCellValue('Nomor Ortu');
      sheetObject.cell(CellIndex.indexByString('H1')).value = TextCellValue('Kelas');
      sheetObject.cell(CellIndex.indexByString('I1')).value = TextCellValue('Agama');
      sheetObject.cell(CellIndex.indexByString('J1')).value = TextCellValue('Mata Pelajaran');
      sheetObject.cell(CellIndex.indexByString('K1')).value = TextCellValue('Profil Picture');

      // Tambahkan contoh data
      sheetObject.cell(CellIndex.indexByString('A2')).value = TextCellValue('Budi Santoso');
      sheetObject.cell(CellIndex.indexByString('B2')).value = TextCellValue('23944');
      sheetObject.cell(CellIndex.indexByString('C2')).value = TextCellValue('0094742844');
      sheetObject.cell(CellIndex.indexByString('D2')).value = TextCellValue('budi@gmail.com');
      sheetObject.cell(CellIndex.indexByString('E2')).value = TextCellValue('123456');
      sheetObject.cell(CellIndex.indexByString('F2')).value = TextCellValue('siswa');
      sheetObject.cell(CellIndex.indexByString('G2')).value = TextCellValue('08123456789');
      sheetObject.cell(CellIndex.indexByString('H2')).value = TextCellValue('7A');
      sheetObject.cell(CellIndex.indexByString('I2')).value = TextCellValue('Islam');
      sheetObject.cell(CellIndex.indexByString('J2')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('K2')).value = TextCellValue('-');

      sheetObject.cell(CellIndex.indexByString('A3')).value = TextCellValue('Aji Harsono');
      sheetObject.cell(CellIndex.indexByString('B3')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('C3')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('D3')).value = TextCellValue('aji@gmail.com');
      sheetObject.cell(CellIndex.indexByString('E3')).value = TextCellValue('123456');
      sheetObject.cell(CellIndex.indexByString('F3')).value = TextCellValue('guru');
      sheetObject.cell(CellIndex.indexByString('G3')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('H3')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('I3')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('J3')).value = TextCellValue('1'); // ID mata pelajaran
      sheetObject.cell(CellIndex.indexByString('K3')).value = TextCellValue('-');

      sheetObject.cell(CellIndex.indexByString('A4')).value = TextCellValue('kristian gundiga');
      sheetObject.cell(CellIndex.indexByString('B4')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('C4')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('D4')).value = TextCellValue('kristian@gmail.com');
      sheetObject.cell(CellIndex.indexByString('E4')).value = TextCellValue('123456');
      sheetObject.cell(CellIndex.indexByString('F4')).value = TextCellValue('admin');
      sheetObject.cell(CellIndex.indexByString('G4')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('H4')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('I4')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('J4')).value = TextCellValue('-');
      sheetObject.cell(CellIndex.indexByString('K4')).value = TextCellValue('-');

      // Header untuk daftar mata pelajaran
      sheetObject.cell(CellIndex.indexByString('M1')).value = TextCellValue('ID');
      sheetObject.cell(CellIndex.indexByString('N1')).value = TextCellValue('Mata Pelajaran');
      sheetObject.cell(CellIndex.indexByString('O1')).value = TextCellValue('Status');

      // Ambil data mata pelajaran dari state bloc
      final mataPelajaranState = context.read<MataPelajaranBloc>().state;

      if (mataPelajaranState is MataPelajaranLoaded) {
        mataPelajaranList = mataPelajaranState.mataPelajaranList;
      }

      // Isi data mata pelajaran dari database
      for (int i = 0; i < mataPelajaranList.length; i++) {
        final mataPelajaran = mataPelajaranList[i];
        final row = i + 2; // Mulai dari baris 2

        sheetObject.cell(CellIndex.indexByString('M$row')).value = TextCellValue(mataPelajaran.id.toString());
        sheetObject.cell(CellIndex.indexByString('N$row')).value = TextCellValue(mataPelajaran.mapel);
        sheetObject.cell(CellIndex.indexByString('O$row')).value = TextCellValue(
            mataPelajaran.keyStatus == 'active' ? 'Aktif' : 'Nonaktif'
        );
      }

      // Tambahkan catatan penggunaan
      final startNoteRow = mataPelajaranList.length + 4;
      sheetObject.cell(CellIndex.indexByString('M$startNoteRow')).value = TextCellValue('Catatan:');
      sheetObject.cell(CellIndex.indexByString('M${startNoteRow + 1}')).value = TextCellValue('1. Untuk role guru, isi kolom "Mata Pelajaran" dengan ID mata pelajaran');
      sheetObject.cell(CellIndex.indexByString('M${startNoteRow + 2}')).value = TextCellValue('2. Untuk role siswa, isi kolom "Mata Pelajaran" dengan "-"');
      sheetObject.cell(CellIndex.indexByString('M${startNoteRow + 3}')).value = TextCellValue('3. Untuk role admin, isi kolom "Mata Pelajaran" dengan "-"');
      sheetObject.cell(CellIndex.indexByString('M${startNoteRow + 4}')).value = TextCellValue('4. Gunakan ID mata pelajaran dari tabel di atas');

      // Deteksi environment dan platform
      bool isWeb = kIsWeb;
      String basePath = '/storage/emulated/0/Download';
      String baseFileName = 'template_import_user';
      String fileExtension = '.xlsx';
      String message = '';

      if (isWeb) {
        await _downloadForWeb(excel);
        message = 'Template sedang didownload...';
      } else {

        // Untuk non-web, generate nama file yang unik
        String filePath = await _getUniqueFilePath(basePath, baseFileName, fileExtension);

        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(excel.save()!);
        message = 'Template sedang didownload...';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Fungsi untuk mendapatkan path file yang unik
  Future<String> _getUniqueFilePath(String directory, String baseName, String extension) async {
    String filePath = '$directory/$baseName$extension';
    File file = File(filePath);
    int counter = 1;

    // Cek jika file sudah ada, tambahkan angka (1), (2), dst.
    while (await file.exists()) {
      String newFileName = '$baseName ($counter)$extension';
      filePath = '$directory/$newFileName';
      file = File(filePath);
      counter++;
    }

    return filePath;
  }

  Future<void> _downloadForWeb(Excel excel) async {
    excel.save(fileName: 'template_import_user.xlsx');
  }

  Future<void> _importUsersFromExcel(String token) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        Uint8List bytes;

        // Handle perbedaan platform
        if (kIsWeb) {
          // Untuk web
          bytes = result.files.first.bytes!;
        } else {
          // Untuk mobile/desktop
          File file = File(result.files.single.path!);
          bytes = await file.readAsBytes();
        }

        await _processExcelData(bytes, token);
      }
    } catch (e) {
      _showErrorSnackBar('Error importing file: $e');
    }
  }

  Future<void> _processExcelData(Uint8List bytes, String token) async {
    try {
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        int rowIndex = 0;
        for (var row in excel.tables[table]!.rows) {
          // Skip header row
          if (rowIndex == 0) {
            rowIndex++;
            continue;
          }

          // Validasi row tidak kosong
          if (row.isEmpty || row[0]?.value == null) {
            rowIndex++;
            continue;
          }

          // Extract data dengan validasi
          String nama = _getCellValue(row[0]);
          if (nama.isEmpty) {
            rowIndex++;
            continue;
          }

          String nis = _getCellValue(row[1]);
          String nisn = _getCellValue(row[2]);
          String email = _getCellValue(row[3]);
          String password = _getCellValue(row[4]);
          String role = _getCellValue(row[5]);
          String nomorOrtu = _getCellValue(row[6]);
          String kelas = _getCellValue(row[7], defaultValue: '-');
          String agama = _getCellValue(row[8], defaultValue: '-');
          int id_mapel = int.tryParse(_getCellValue(row[9])) ?? 0;
          String profpic = _getCellValue(row[10], defaultValue: '-');
          int poin = 0;
          String keyStatus = 'active';

          // Tambahkan delay untuk menghindari overload
          await Future.delayed(const Duration(milliseconds: 100));

          // Add user via BLoC event
          if (context.mounted) {
            context.read<UsersBloc>().add(
              AddUsers(
                token: token,
                nama: nama,
                nis: nis,
                nisn: nisn,
                email: email,
                password: password,
                role: role,
                nomorOrtu: nomorOrtu,
                kelas: kelas,
                agama: agama,
                id_mapel: id_mapel,
                poin: poin,
                profpic: profpic,
                keyStatus: keyStatus,
              ),
            );
          }

          rowIndex++;
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error processing Excel data: $e');
    }
  }

  String _getCellValue(Data? cell, {String defaultValue = ''}) {
    if (cell == null || cell.value == null) return defaultValue;

    return cell.value.toString().trim();
  }

  void _showErrorSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}