import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;
import 'package:open_file/open_file.dart';

class RapotGuruScreen extends StatefulWidget {
  const RapotGuruScreen({super.key});

  @override
  State<RapotGuruScreen> createState() => _RapotGuruScreenState();
}

class _RapotGuruScreenState extends State<RapotGuruScreen> {
  String selectedClass = '7A'; // Default selected class
  List<String> classes = ['7A', '7B', '8A', '8B', '9A', '9B']; // Example classes
  List<StudentGrade> studentGrades = []; // Will be populated based on selected class

  @override
  void initState() {
    super.initState();
    _loadStudentGrades(); // Load initial data
  }

  void _loadStudentGrades() {
    // This is mock data - in a real app, you would fetch this from an API/database
    // based on the selected class and the teacher's subject
    setState(() {
      studentGrades = [
        StudentGrade(1, 'Ani', 80, 85),
        StudentGrade(2, 'Budi', 75, 78),
        StudentGrade(3, 'Citra', 90, 92),
        StudentGrade(4, 'Doni', 65, 70),
        StudentGrade(5, 'Eka', 85, 88),
      ];
    });
  }

  Future<void> _exportToExcel() async {
    // Create a new Excel document
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // Add headers
    sheet.getRangeByIndex(1, 1).setText('No');
    sheet.getRangeByIndex(1, 2).setText('Nama');
    sheet.getRangeByIndex(1, 3).setText('UTS');
    sheet.getRangeByIndex(1, 4).setText('UAS');

    // Add data
    for (var i = 0; i < studentGrades.length; i++) {
      final student = studentGrades[i];
      sheet.getRangeByIndex(i + 2, 1).setNumber(student.no.toDouble());
      sheet.getRangeByIndex(i + 2, 2).setText(student.nama);
      sheet.getRangeByIndex(i + 2, 3).setNumber(student.uts.toDouble());
      sheet.getRangeByIndex(i + 2, 4).setNumber(student.uas.toDouble());
    }

    // Auto-fit columns
    sheet.getRangeByName('A1:D1').autoFitColumns();

    // Save the document
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // Save the file and open it
    // Note: You'll need to implement proper file saving logic for your platform
    // This is a simplified version
    // In a real app, use path_provider and file_picker packages
    // For demonstration, we'll just show a snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diexport ke Excel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        _loadStudentGrades();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SfDataGrid(
                source: StudentGradeDataSource(studentGrades),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportToExcel,
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
  StudentGradeDataSource(List<StudentGrade> students) {
    _studentGrades = students
        .map((student) => DataGridRow(cells: [
      DataGridCell<int>(columnName: 'no', value: student.no),
      DataGridCell<String>(columnName: 'nama', value: student.nama),
      DataGridCell<int>(columnName: 'uts', value: student.uts),
      DataGridCell<int>(columnName: 'uas', value: student.uas),
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