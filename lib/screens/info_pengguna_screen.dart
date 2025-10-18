import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/user/user_state.dart';
import 'package:project_ta/constants/color.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/user/user_bloc.dart';
import 'ganti_password_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class InfoPenggunaScreen extends StatelessWidget {
  const InfoPenggunaScreen({super.key});

  showAlertDialog(context) => showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('Permission Denied'),
      content: const Text('Allow access to gallery and photos'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => openAppSettings(),
          child: const Text('Settings'),
        ),
      ],
    ),
  );



  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final List<String> monthNames = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Info Pengguna',
          style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<UserBloc, UserState>(
              builder: (context, userState){
                if(authState is! Authenticated) {
                  return Text("Login Dulu");
                } else if(userState is UserLoaded){
                  return Column(
                    children: [
                      // Foto Profil Besar
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundImage: userState.profpic != '-'
                                  ? NetworkImage(userState.profpic)
                                  : AssetImage('assets/icons/avatar-default-icon.png') as ImageProvider,
                              backgroundColor: Colors.grey[200],
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
                              if(authState.kelas != '-')
                                _buildInfoField('Kelas', userState.kelas),
                              if(authState.mapel != '-')
                                _buildInfoField('Mata Pelajaran', userState.mapel),
                              const Divider(height: 24),
                              _buildInfoField('Bergabung Sejak', '${authState.timestamps.day} ${monthNames[authState.timestamps.month]} ${authState.timestamps.year}'),
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
                            // Navigasi ke halaman Ganti Password
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GantiPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Ganti Password',
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