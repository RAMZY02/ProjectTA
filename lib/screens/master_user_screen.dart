import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/users/users_bloc.dart';
import 'package:project_ta/bloc/users/users_event.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/users/users_state.dart';
import 'insert_user_screen.dart';

class MasterUserScreen extends StatefulWidget {
  const MasterUserScreen({super.key});

  @override
  State<MasterUserScreen> createState() => _MasterUserScreenState();
}

class _MasterUserScreenState extends State<MasterUserScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
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
            child: BlocBuilder<UsersBloc, UsersState>(
              builder: (context, usersState){
                if(authState is! Authenticated){
                  return Text("Login Dulu min");
                }
                if (usersState is! UsersLoaded || usersState.users.isEmpty || usersState is UsersInitial) {
                  Future.microtask(() {
                    context.read<UsersBloc>().add(FetchUsers(token: authState.token));
                  });
                }
                if(usersState is UsersLoaded){
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Kelas')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: usersState.users.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user.id.toString())),
                            DataCell(Text(user.nama)),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.role)),
                            DataCell(Text(user.kelas)),
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
                                    onPressed: () => _deleteUser(authState.token, user.id),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
                else{
                  return CircularProgressIndicator();
                }
              }
            )
          ),
        ],
      ),
    );
  }

  void _deleteUser(String token, int id) {
    context.read<UsersBloc>().add(DeleteUsers(token: token, id_user: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User deleted successfully')),
    );
  }
}