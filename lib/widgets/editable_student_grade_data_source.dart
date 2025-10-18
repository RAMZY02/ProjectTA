import 'package:flutter/material.dart';
import 'package:project_ta/models/laporan_tugas_model.dart';
import 'package:project_ta/models/nilai_akhir_siswa_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/ujian_harian_model.dart';
import '../models/user_model.dart';

class EditableStudentGradeDataSource extends DataGridSource {
  final int idMapel;
  final List<UserModel> students;
  final int jumlahTugas;
  final int id_tahun_pelajaran;
  final List<String> tugasHeaders;
  final List<UjianHarianModel> allUjianHarian;
  final List<LaporanTugasModel> allLaporanTugas;
  final List<NilaiAkhirSiswaModel> allCapaianKompetensi;
  final String Function(UserModel, int) getNilaiUjianHarian;
  final String Function(UserModel, int) getNilaiLaporanTugas;
  final String Function(UserModel, int) getNilaiTugas;
  final String Function(UserModel, int) getCapaianKompetensi;
  final int Function(UserModel) hitungNilaiAkhir;
  final Function(UserModel, int, String) onNilaiTugasChanged;
  final Function(UserModel, String) onCapaianChanged;

  EditableStudentGradeDataSource({
    required this.idMapel,
    required this.students,
    required this.jumlahTugas,
    required this.id_tahun_pelajaran,
    required this.tugasHeaders,
    required this.allUjianHarian,
    required this.allLaporanTugas,
    required this.allCapaianKompetensi,
    required this.getNilaiUjianHarian,
    required this.getNilaiLaporanTugas,
    required this.getNilaiTugas,
    required this.getCapaianKompetensi,
    required this.hitungNilaiAkhir,
    required this.onNilaiTugasChanged,
    required this.onCapaianChanged,
  }) {
    _buildDataGridRows();
  }

  List<DataGridRow> _studentGrades = [];

  void _buildDataGridRows() {
    int counter = 0;
    _studentGrades = students.map((student) {
      final cells = <DataGridCell>[
        DataGridCell<int>(columnName: 'No', value: ++counter),
        DataGridCell<String>(columnName: 'Nama', value: student.nama),
      ];

      // Cells untuk latihan (editable)
      for (int i = 0; i < jumlahTugas; i++) {
        cells.add(DataGridCell<String>(
          columnName: 'Latihan $i',
          value: getNilaiTugas(student, i),
        ));
      }

      // Cells untuk tugas
      int counter1 = 0;
      for (final tugas in allLaporanTugas) {
        final nilai = getNilaiLaporanTugas(student, tugas.id);
        cells.add(DataGridCell<String>(
            columnName: 'Tugas ${++counter1}',
            value: nilai
        ));
      }

      // Cells untuk ujian harian
      int counter2 = 0;
      for (final ujian in allUjianHarian) {
        final nilai = getNilaiUjianHarian(student, ujian.id);
        cells.add(DataGridCell<String>(
            columnName: 'UH ${++counter2}',
            value: nilai
        ));
      }

      // Cells untuk kolom lainnya
      cells.addAll([
        DataGridCell<String>(columnName: 'UTS', value: student.uts),
        DataGridCell<String>(columnName: 'UAS', value: student.uas),
        DataGridCell<int>(columnName: 'NA', value: hitungNilaiAkhir(student)),
        DataGridCell<String>(columnName: 'Capaian Kompetensi', value: getCapaianKompetensi(student, idMapel)),
      ]);

      return DataGridRow(cells: cells);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _studentGrades;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowIndex = rows.indexOf(row);
    final student = students[rowIndex];

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        final isTugasCell = dataGridCell.columnName.startsWith('Latihan ');
        final isCapaianCell = dataGridCell.columnName.startsWith('Capaian ');
        final isNamaCell = dataGridCell.columnName == 'Nama';

        return Container(
          alignment: isNamaCell
              ? Alignment.centerLeft // Align left untuk kolom Nama
              : Alignment.center, // Center untuk kolom lainnya
          padding: const EdgeInsets.all(8.0),
          child: isTugasCell
              ? _buildEditableCell(student, dataGridCell)
              : isCapaianCell ? _buildEditableCapaianCell(student, dataGridCell) : Text(
            dataGridCell.value.toString(),
            textAlign: isNamaCell
                ? TextAlign.left // Text align left untuk kolom Nama
                : TextAlign.center, // Center untuk kolom lainnya
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEditableCell(UserModel student, DataGridCell cell) {
    final tugasIndex = int.parse(cell.columnName.split(' ')[1]);

    return StatefulBuilder(
      builder: (context, setState) {
        final currentValue = getNilaiTugas(student, tugasIndex); // Pindahkan ke sini
        print('ini value dari tugas $currentValue');
        final controller = TextEditingController(text: currentValue);
        final focusNode = FocusNode();

        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            onNilaiTugasChanged(student, tugasIndex, controller.text);
          }
        });

        return TextFormField(
          key: ValueKey('${student.id}_tugas_${tugasIndex}_$id_tahun_pelajaran'), // KEY UNIK
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(4.0),
          ),
        );
      },
    );
  }

  Widget _buildEditableCapaianCell(UserModel student, DataGridCell cell) {
    return StatefulBuilder(
      builder: (context, setState) {
        final currentValue = getCapaianKompetensi(student, idMapel);
        final controller = TextEditingController(text: currentValue);
        final focusNode = FocusNode();

        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            onCapaianChanged(student, controller.text);
          }
        });

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300, // MAX WIDTH 300
          ),
          child: TextFormField(
            key: ValueKey('${student.id}_$id_tahun_pelajaran'), // KEY UNIK
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLines: 5, // MAX LINES 5
            minLines: 1, // MIN LINES 1
            style: TextStyle(
              fontSize: 12.0, // UKURAN TULISAN YANG SESUAI
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(4.0),
              isDense: true, // MEMPERKECIL PADDING INTERNAL
            ),
          ),
        );
      },
    );
  }
}