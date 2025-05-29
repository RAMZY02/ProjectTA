import 'package:flutter/material.dart';
import 'package:project_ta/constants/color.dart';
import 'dart:math' as math;

class TemanKelasScreen extends StatelessWidget {
  const TemanKelasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teman Kelas 7A', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: classmates.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final student = classmates[index];
          return _buildClassmateCard(student);
        },
      ),
    );
  }

  Widget _buildClassmateCard(Classmate student) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            // Bagian kiri - Foto & Info Dasar
            Container(
              constraints: BoxConstraints(
                maxWidth: 110,
                minWidth: 110
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(student.profilePhoto),
                      ),
                      if (student.rank <= 3) // Hanya tampilkan medali untuk 3 besar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getRankColor(student.rank),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getRankIcon(student.rank),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatName(student.name),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika masih panjang
                  ),
                  Text(
                    'Peringkat #${student.rank}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8),

            // Bagian kanan - Mata Pelajaran Unggulan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mata Pelajaran Unggulan:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getSubjectIcon(student.bestSubject),
                        color: _getSubjectColor(student.bestSubject),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        student.bestSubject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nilai Tertinggi: ${student.highestScore}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  LinearProgressIndicator(
                    value: student.highestScore / 100,
                    backgroundColor: Colors.grey[200],
                    color: _getSubjectColor(student.bestSubject),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatName(String fullName, {int maxLength = 12}) {
    // Jika nama sudah pendek, kembalikan langsung
    if (fullName.length <= maxLength) return fullName;

    final names = fullName.split(' ');

    // Jika hanya 1 kata, potong saja
    if (names.length == 1) {
      return fullName.substring(0, maxLength);
    }

    // Format nama dengan singkatan
    String formatted = names[0]; // Nama depan

    for (int i = 1; i < names.length; i++) {
      if (i == names.length - 1) {
        // Nama belakang utuh jika masih cukup panjang
        if (formatted.length + 1 + names[i].length <= maxLength) {
          formatted += ' ${names[i]}';
        } else {
          formatted += ' ${names[i][0]}.'; // Singkatan jika terlalu panjang
        }
      } else {
        // Singkatan untuk nama tengah
        formatted += ' ${names[i][0]}.';
      }

      // Berhenti jika sudah mencapai batas
      if (formatted.length >= maxLength) break;
    }

    return formatted.substring(0, math.min(formatted.length, maxLength));
  }

  // Helper functions untuk tampilan
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey;
      case 3: return Colors.brown;
      default: return Colors.blue;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1: return Icons.emoji_events;
      case 2: return Icons.workspace_premium;
      case 3: return Icons.workspace_premium;
      default: return Icons.star;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Matematika': return Colors.red;
      case 'Bahasa Indonesia': return Colors.blue;
      case 'IPA': return Colors.green;
      case 'Bahasa Inggris': return Colors.purple;
      case 'IPS': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Matematika': return Icons.calculate;
      case 'Bahasa Indonesia': return Icons.menu_book;
      case 'IPA': return Icons.science;
      case 'Bahasa Inggris': return Icons.language;
      case 'IPS': return Icons.public;
      default: return Icons.subject;
    }
  }
}

class Classmate {
  final String name;
  final String profilePhoto;
  final int rank;
  final String bestSubject;
  final int highestScore;

  Classmate({
    required this.name,
    required this.profilePhoto,
    required this.rank,
    required this.bestSubject,
    required this.highestScore,
  });
}

final List<Classmate> classmates = [
  Classmate(
    name: 'Riviera Amirna Fadila',
    profilePhoto: 'https://randomuser.me/api/portraits/women/1.jpg',
    rank: 1,
    bestSubject: 'Matematika',
    highestScore: 98,
  ),
  Classmate(
    name: 'Daffa Tsaqif Muhammad',
    profilePhoto: 'https://randomuser.me/api/portraits/men/2.jpg',
    rank: 2,
    bestSubject: 'IPA',
    highestScore: 95,
  ),
  Classmate(
    name: 'Citra Dewi',
    profilePhoto: 'https://randomuser.me/api/portraits/women/3.jpg',
    rank: 3,
    bestSubject: 'Bahasa Inggris',
    highestScore: 93,
  ),
  Classmate(
    name: 'Ramaditya Satriawan',
    profilePhoto: 'https://randomuser.me/api/portraits/men/4.jpg',
    rank: 4,
    bestSubject: 'Bahasa Indonesia',
    highestScore: 89,
  ),
  Classmate(
    name: 'Eka Wulandari',
    profilePhoto: 'https://randomuser.me/api/portraits/women/5.jpg',
    rank: 5,
    bestSubject: 'IPS',
    highestScore: 87,
  ),
];