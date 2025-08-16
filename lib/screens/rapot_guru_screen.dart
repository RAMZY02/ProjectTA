import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/users/users_state.dart';
import 'package:project_ta/models/user_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;
import 'package:open_file/open_file.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/users/users_bloc.dart';
import '../bloc/users/users_event.dart';

class RapotGuruScreen extends StatefulWidget {
  const RapotGuruScreen({super.key});

  @override
  State<RapotGuruScreen> createState() => _RapotGuruScreenState();
}

class _RapotGuruScreenState extends State<RapotGuruScreen> {
  String selectedClass = '7D'; // Default selected class
  List<String> classes = ['7D']; // Example classes
  List<StudentGrade> studentGrades = []; // Will be populated based on selected class

  @override
  void initState() {
    super.initState();
  }

  void _loadStudentGrades(AuthState authState, BuildContext context) {
    if(authState is Authenticated){
      context.read<UsersBloc>().add(LoadRapot(token: authState.token, kelas: selectedClass, mapel: authState.mapel));
    }
  }

  Future<void> _exportToExcel(AuthState authState, BuildContext context) async {
    try{
      if(authState is! Authenticated) return;
      // Get the current state
      final usersState = context.read<UsersBloc>().state;

      if (usersState is! UsersLoaded || usersState.users.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data untuk diexport')),
        );
        return;
      }

      // Create a new Excel document
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Add headers with styling
      final Range headerRange = sheet.getRangeByIndex(1, 1, 1, 4);
      headerRange.cellStyle.bold = true;

      sheet.getRangeByIndex(1, 1).setText('No');
      sheet.getRangeByIndex(1, 2).setText('Nama');
      sheet.getRangeByIndex(1, 3).setText('UTS');
      sheet.getRangeByIndex(1, 4).setText('UAS');

      // Add data
      for (var i = 0; i < usersState.users.length; i++) {
        final student = usersState.users[i];
        sheet.getRangeByIndex(i + 2, 1).setNumber((i + 1).toDouble());
        sheet.getRangeByIndex(i + 2, 2).setText(student.nama);

        // Handle UTS and UAS conversion safely
        final uts = int.tryParse(student.uts) ?? 0;
        final uas = int.tryParse(student.uas) ?? 0;

        sheet.getRangeByIndex(i + 2, 3).setNumber(uts.toDouble());
        sheet.getRangeByIndex(i + 2, 4).setNumber(uas.toDouble());
      }

      // Auto-fit columns
      sheet.getRangeByName('A1:D${usersState.users.length + 1}').autoFitColumns();

      // Save the document
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // Get directory for saving to Download folder
      final path = '/storage/emulated/0/Download/Rapot_${authState.mapel}_Kelas_$selectedClass.xlsx';

      // Write to file
      final File file = File(path);
      await file.writeAsBytes(bytes);

      // Open the file
      await OpenFile.open(path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil diexport ke Download')),
        );
      }
    }
    catch(e){
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menemukan folder Download untuk menyimpan file')),
        );
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    _loadStudentGrades(authState, context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor Guru'),
      ),
      body: Column(
        children: [
          // Horizontal scrollable class selector
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
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          BlocBuilder<UsersBloc, UsersState>(
            builder: (context, usersState){
              if(usersState is UsersLoaded){
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SfDataGrid(
                      source: StudentGradeDataSource(usersState.users),
                      columns: [
                        GridColumn(
                          columnName: 'no',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: const Text('No'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'nama',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: const Text('Nama'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'uts',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: const Text('UTS'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'uas',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: const Text('UAS'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              else if(usersState is UsersLoading){
                return Center(child: CircularProgressIndicator());
              }
              else{
                return Text("Belum ada data tersedia");
              }
            }
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _exportToExcel(authState, context);
        },
        tooltip: 'Export to Excel',
        child: const Icon(Icons.download),
      ),
    );
  }
}

class StudentGrade {
  final int no;
  final String nama;
  final int uts;
  final int uas;

  StudentGrade(this.no, this.nama, this.uts, this.uas);
}

class StudentGradeDataSource extends DataGridSource {
  StudentGradeDataSource(List<UserModel> state) {
    int counter = 0;
    _studentGrades = state.map((student) => DataGridRow(cells: [
      DataGridCell<int>(columnName: 'no', value: ++counter),
      DataGridCell<String>(columnName: 'nama', value: student.nama),
      DataGridCell<String>(columnName: 'uts', value: student.uts),
      DataGridCell<String>(columnName: 'uas', value: student.uas),
    ]))
        .toList();
  }

  List<DataGridRow> _studentGrades = [];

  @override
  List<DataGridRow> get rows => _studentGrades;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList());
  }
}