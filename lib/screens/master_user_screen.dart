import 'package:flutter/material.dart';

import 'insert_user_screen.dart';

class MasterUserScreen extends StatefulWidget {
  const MasterUserScreen({super.key});

  @override
  State<MasterUserScreen> createState() => _MasterUserScreenState();
}

class _MasterUserScreenState extends State<MasterUserScreen> {
  // Sample Data
  List<Map<String, dynamic>> _users = [
    {'id': 1, 'name': 'John Doe', 'email': 'john@example.com', 'role': 'Admin'},
    {'id': 2, 'name': 'Jane Smith', 'email': 'jane@example.com', 'role': 'User'},
  ];

  void _deleteUser(int id) {
    setState(() {
      _users.removeWhere((user) => user['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tambah User'),
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
          const SizedBox(height: 16),
          // DataTable
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _users.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user['id'].toString())),
                      DataCell(Text(user['name'])),
                      DataCell(Text(user['email'])),
                      DataCell(Text(user['role'])),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Navigate to Edit Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InsertUserScreen(
                                      userData: user,
                                      isEdit: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(user['id']),
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
        ],
      ),
    );
  }
}