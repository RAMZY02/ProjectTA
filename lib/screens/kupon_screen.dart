import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:project_ta/constants/color.dart';

class KuponScreen extends StatelessWidget {
  const KuponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kupon'),
        centerTitle: true,
        backgroundColor: const Color(0xff6849ef),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: coupons.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return _buildCouponCard(context, coupon);
        },
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, Coupon coupon) {
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
                  color: coupon.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  coupon.icon,
                  color: coupon.color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jenis: ${coupon.type}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Didapatkan: ${coupon.date}',
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

  void _showCouponBarcode(BuildContext context, Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(coupon.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Jenis: ${coupon.type}'),
            const SizedBox(height: 16),
            BarcodeWidget(
              barcode: Barcode.code128(), // Jenis barcode
              data: coupon.barcodeData, // Data unik untuk barcode
              width: 200,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(
              'Tunjukkan barcode ini ke guru yang ada diruang osis',
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

class Coupon {
  final IconData icon;
  final String title;
  final String type;
  final String date;
  final Color color;
  final String barcodeData; // Data unik untuk barcode

  Coupon({
    required this.icon,
    required this.title,
    required this.type,
    required this.date,
    required this.color,
    required this.barcodeData,
  });
}

final List<Coupon> coupons = [
  Coupon(
    icon: Icons.edit,
    title: 'Pensil Warna Premium',
    type: 'Alat Tulis',
    date: '15 April 2024',
    color: Colors.blue,
    barcodeData: 'AT-001-10042025', // Format: Jenis-Nomor-Tanggal
  ),
  Coupon(
    icon: Icons.cake,
    title: 'Donat Coklat',
    type: 'Jajanan',
    date: '12 April 2024',
    color: Colors.brown,
    barcodeData: 'JJ-001-20240412',
  ),
  Coupon(
    icon: Icons.edit,
    title: 'Buku Tulis Keren',
    type: 'Alat Tulis',
    date: '10 April 2024',
    color: Colors.blue,
    barcodeData: 'AT-002-20240410',
  ),
  Coupon(
    icon: Icons.cake,
    title: 'Es Krim Vanilla',
    type: 'Jajanan',
    date: '5 April 2024',
    color: Colors.brown,
    barcodeData: 'JJ-002-20240405',
  ),
  Coupon(
    icon: Icons.edit,
    title: 'Stabilo 4 Warna',
    type: 'Alat Tulis',
    date: '1 April 2024',
    color: Colors.blue,
    barcodeData: 'AT-003-20240401',
  ),
];