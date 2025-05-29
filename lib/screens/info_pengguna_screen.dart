import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/user/user_state.dart';
import 'package:project_ta/constants/color.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/user/user_bloc.dart';

class InfoPenggunaScreen extends StatelessWidget {
  const InfoPenggunaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final List<String> monthNames = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Pengguna'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState){
            if(authState is! Authenticated) return Text("Login Dulu");
            else if(userState is UserLoaded){
              return Column(
                children: [
                  // Foto Profil Besar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(userState.profpic),
                          backgroundColor: Colors.grey,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Data Pengguna
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoField('Nama Lengkap', userState.username),
                          const Divider(height: 24),
                          _buildInfoField('Email', userState.email),
                          const Divider(height: 24),
                          _buildInfoField('Kelas', userState.kelas),
                          const Divider(height: 24),
                          _buildInfoField('Bergabung Sejak', '${userState.timestamps.day} ${monthNames[userState.timestamps.month]} ${userState.timestamps.year}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Edit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Aksi untuk edit profil
                      },
                      child: const Text(
                        'Edit Profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        )
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}