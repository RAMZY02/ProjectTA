import 'package:flutter/material.dart';
import 'package:project_ta/screens/pemeriksaan_jawaban_screen.dart';

class DaftarSiswaScreen extends StatefulWidget {
  final Map<String, dynamic> ujian;

  const DaftarSiswaScreen({super.key, required this.ujian});

  @override
  State<DaftarSiswaScreen> createState() => _DaftarSiswaScreenState();
}

class _DaftarSiswaScreenState extends State<DaftarSiswaScreen> {
  String selectedClass = '7A';
  final List<String> classes = ['7A', '7B', '7C', '7D', '7E', '7F', '7G', '7H', '7I', '7J'];

  // Mock data for students
  final Map<String, List<Map<String, dynamic>>> studentsByClass = {
    '7A': [
      {'id': '1', 'name': 'Ani', 'score': null},
      {'id': '2', 'name': 'Budi', 'score': 85},
      {'id': '3', 'name': 'Citra', 'score': null},
    ],
    '7B': [
      {'id': '4', 'name': 'Dewi', 'score': 78},
      {'id': '5', 'name': 'Eka', 'score': null},
      {'id': '6', 'name': 'Fajar', 'score': 92},
    ],
    // Add more classes as needed
  };

  @override
  void initState() {
    super.initState();
    // Initialize with empty list if class doesn't exist
    studentsByClass.putIfAbsent(selectedClass, () => []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Siswa - ${widget.ujian['title']}'),
      ),
      body: Column(
        children: [
          // Class selector navbar
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
                        // Initialize with empty list if class doesn't exist
                        studentsByClass.putIfAbsent(selectedClass, () => []);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          // Student list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: studentsByClass[selectedClass]!.length,
              itemBuilder: (context, index) {
                final student = studentsByClass[selectedClass]![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(student['name']),
                    trailing: student['score'] != null
                        ? Text(
                      'Nilai: ${student['score']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                        : const Text(
                      'Belum dinilai',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PemeriksaanJawabanScreen(examData: widget.ujian, student: student, studentClass: selectedClass)
                        )
                      ).then((value) {
                        // This will be called when returning from PemeriksaanJawabanScreen
                        if (value != null) {
                          setState(() {
                            // Update the student's score
                            studentsByClass[selectedClass]![index]['score'] = value;
                          });
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}