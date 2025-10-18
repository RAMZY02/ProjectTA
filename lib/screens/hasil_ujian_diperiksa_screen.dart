import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ujian/ujian_bloc.dart';
import '../bloc/ujian/ujian_event.dart';
import '../constants/color.dart';
import 'bottom_navbar_siswa_screen.dart';

class HasilUjianDiperiksaScreen extends StatelessWidget {
  const HasilUjianDiperiksaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Ujian', style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Status Ujian',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Icon(
                        Icons.hourglass_top,
                        size: 48,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Ujian akan diperiksa terlebih dahulu, hasil akan muncul pada history ujian setelah guru anda selesai memeriksa ujian anda',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<UjianBloc>().add(InitUjian());
                  SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.manual,
                      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomNavbarSiswaScreen(initialIndex: 1),
                    ),
                  );
                },
                child: const Text('Kembali ke Beranda'),
              ),
            )
          ],
        )
      )
    );
  }
}
