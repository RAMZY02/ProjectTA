import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_event.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_event.dart';
import 'package:project_ta/bloc/hadiah/hadiah_state.dart';
import 'package:project_ta/bloc/user/user_bloc.dart';
import 'package:project_ta/bloc/user/user_event.dart';
import 'package:project_ta/bloc/user/user_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/hadiah_model.dart';

import '../bloc/auth/auth_bloc.dart';

class HadiahScreen extends StatefulWidget {
  const HadiahScreen({super.key});

  @override
  State<HadiahScreen> createState() => _HadiahScreenState();
}

class _HadiahScreenState extends State<HadiahScreen> {

  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    if(userState is UserLoaded) _userPoints = userState.poin;
  }

  void _tukarHadiah(int hadiahId) {
    final hadiahState = context.read<HadiahBloc>().state;
    final authState = context.read<AuthBloc>().state;
    late HadiahModel hadiah;

    if(authState is! Authenticated) return;
    if(hadiahState is HadiahLoaded) hadiah = hadiahState.hadiah.firstWhere((h) => h.id == hadiahId);

    if (_userPoints < hadiah.poin) {
      _showAlertDialog(
        'Poin Tidak Cukup',
        'Maaf, poin Anda tidak cukup untuk menukar hadiah ini. Anda membutuhkan ${hadiah.poin} poin.',
      );
      return;
    }

    if (hadiah.stok <= 0) {
      _showAlertDialog(
        'Stok Habis',
        'Maaf, stok hadiah ini sudah habis.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Text('Anda yakin ingin menukar ${hadiah.nama} dengan ${hadiah.poin} poin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userPoints -= hadiah.poin;
              });
              if(hadiahState is HadiahLoaded){
                context.read<HadiahBloc>().add(TukarHadiah(token: authState.token, userId: authState.id, hadiahId: hadiahId, hadiah: hadiahState.hadiah));
              }
              context.read<UserBloc>().add(UpdatePoin(token: authState.token, poin: _userPoints));
              Navigator.pop(context);
              _showSuccessDialog(hadiah.nama);
            },
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String namaHadiah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Penukaran Berhasil'),
        content: Text('Anda berhasil menukar $namaHadiah. Hadiah dapat diambil di ruang guru.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ini yang menghilangkan tombol back
        title: const Text(
          'Daftar Hadiah',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize:  18
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
          // Info Poin User
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Poin Anda:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  backgroundColor: Colors.blue[100],
                  label: Text(
                    '$_userPoints Poin',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<HadiahBloc, HadiahState>(
              builder: (context, hadiahState){
                final authState = context.read<AuthBloc>().state;
                if(authState is Authenticated && hadiahState is HadiahInitial){
                  context.read<HadiahBloc>().add(FetchHadiah(
                      token: authState.token,
                  ));
                }

                if(hadiahState is HadiahLoading){
                  return Center(
                    child: CircularProgressIndicator()
                  );
                }
                else if(hadiahState is HadiahLoaded){
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 8, // Horizontal space between items
                      mainAxisSpacing: 8, // Vertical space between items
                      childAspectRatio: 0.43, // Adjust this to control card height relative to width
                    ),
                    itemCount: hadiahState.hadiah.length,
                    itemBuilder: (context, index) {
                      final hadiah = hadiahState.hadiah[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Gambar Hadiah
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                hadiah.link_gambar,
                                height: 240, // Reduced height for grid layout
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),

                            // Info Hadiah
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hadiah.nama,
                                    style: const TextStyle(
                                      fontSize: 16, // Slightly smaller font
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.category, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          hadiah.kategori,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${hadiah.poin} Poin',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.inventory, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Stok: ${hadiah.stok}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Tukar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed: () => _tukarHadiah(hadiah.id),
                                child: const Text(
                                  'TUKAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                else{
                  return Center(
                    child: Text("GG")
                  );
                }
              }
            )
          )
        ],
      ),
    );
  }
}