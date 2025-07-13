import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_event.dart';
import 'package:project_ta/bloc/kupon/kupon_state.dart';

import '../bloc/auth/auth_state.dart';
import '../constants/color.dart';

class AdminKuponScreen extends StatelessWidget {
  const AdminKuponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daftar Kupon",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,// Custom shadow color
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: BlocBuilder<KuponBloc, KuponState>(
          builder: (context, kuponState){
            if(authState is! Authenticated){
              return Text("Login Dulu min");
            }
            if (kuponState is! KuponLoaded || kuponState.kupons.isEmpty || kuponState is KuponInitial) {
              Future.microtask(() {
                context.read<KuponBloc>().add(FetchAllKupon(token: authState.token));
              });
            }
            if(kuponState is KuponLoaded){
              return ListView.builder(
                itemCount: kuponState.kupons.length,
                itemBuilder: (context, index) {
                  final kupon = kuponState.kupons[index];
                  return Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Logo Mata Pelajaran
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                kupon.id.toString(),
                                style: TextStyle(
                                  fontSize: 36,
                                ),
                              )
                          ),
                          const SizedBox(width: 16),
                          // Konten Ujian
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kupon.hadiah.nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  kupon.kode,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            kupon.status,
                            style: TextStyle(
                                fontSize: 18,
                                color: kupon.status == "Claimed" ? Colors.green : Colors.grey
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            else{
              return CircularProgressIndicator();
            }
          }
      )
    );
  }
}
