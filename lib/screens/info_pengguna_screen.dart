import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/user/user_event.dart';
import 'package:project_ta/bloc/user/user_state.dart';
import 'package:project_ta/constants/color.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/user/user_bloc.dart';
import 'ganti_password_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class InfoPenggunaScreen extends StatelessWidget {
  const InfoPenggunaScreen({super.key});

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _getFromGallery(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      // Meminta izin
      final permission = Permission.camera;
      final status = await permission.request();

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin ${permission.toString().split('.').last} dibutuhkan')),
        );
        return;
      }

      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        // Di sini Anda bisa mengupdate foto profil
        print("ini picked file");
        print(pickedFile.path);
        final authState = context
            .read<AuthBloc>()
            .state;
        if (authState is Authenticated) {
          context.read<UserBloc>().add(UpdateProfpic(
              token: authState.token, profpic: pickedFile.path.toString()));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto profil berhasil diubah')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _getFromGallery(BuildContext context) async {
    try {
      // Meminta izin
      final permission = Permission.photos;
      final status = await permission.request();

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin ${permission.toString().split('.').last} dibutuhkan')),
        );
        return;
      }

      XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        print("ini image file");
        print(imageFile);
        final authState = context.read<AuthBloc>().state;
        if(authState is Authenticated){
          context.read<UserBloc>().add(UpdateProfpic(token: authState.token, profpic: imageFile.toString()));
        }
      }
    } catch (e) {
      var status = await Permission.photos.status;
      if (status.isDenied) {
        print('Access Denied');
        showAlertDialog(context);
      } else {
        print('Exception occured!');
      }
    }
  }

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
                              radius: 60,
                              backgroundImage: NetworkImage(userState.profpic),
                              backgroundColor: Colors.grey,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _showImagePickerOptions(context),
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