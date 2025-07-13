import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/kupon/kupon_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_event.dart';
import 'package:project_ta/bloc/kupon/kupon_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/kupon_model.dart';

class SiswaKuponScreen extends StatelessWidget {
  const SiswaKuponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Kupon',
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
      body: BlocBuilder<KuponBloc, KuponState>(
        builder: (context, kuponState){
          if(authState is Authenticated && kuponState is! KuponLoaded){
            context.read<KuponBloc>().add(FetchKupon(token: authState.token, userId: authState.id));
          }
          if(kuponState is KuponLoaded){
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: kuponState.kupons.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final coupon = kuponState.kupons[index];
                return _buildCouponCard(context, coupon);
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

  Widget _buildCouponCard(BuildContext context, KuponModel coupon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showCouponBarcode(context, coupon);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.hadiah.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jenis: ${coupon.hadiah.kategori}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Didapatkan: ${coupon.waktu}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showCouponBarcode(BuildContext context, KuponModel coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(coupon.hadiah.nama),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Jenis: ${coupon.hadiah.kategori}'),
            const SizedBox(height: 16),
            BarcodeWidget(
              barcode: Barcode.qrCode(), // Menggunakan QR code instead of code128
              data: coupon.kode, // Data unik untuk QR code
              width: 200,
              height: 200, // QR code biasanya berbentuk persegi
            ),
            const SizedBox(height: 16),
            Text(
              'Tunjukkan QR code ini ke guru yang ada diruang osis',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TUTUP'),
          ),
        ],
      ),
    );
  }
}