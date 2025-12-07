import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/kupon/kupon_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_event.dart';
import 'package:project_ta/bloc/kupon/kupon_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/kupon_model.dart';

class SiswaKuponScreen extends StatefulWidget {
  const SiswaKuponScreen({super.key});

  @override
  State<SiswaKuponScreen> createState() => _SiswaKuponScreenState();
}

class _SiswaKuponScreenState extends State<SiswaKuponScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<KuponModel> _filteredKupons = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _filterKupons(List<KuponModel> kupons) {
    if (_searchQuery.isEmpty) {
      _filteredKupons = List.from(kupons);
    } else {
      _filteredKupons = kupons.where((kupon) {
        final namaHadiah = kupon.hadiah.nama.toLowerCase();
        final kategori = kupon.hadiah.kategori.toLowerCase();
        return namaHadiah.contains(_searchQuery) ||
            kategori.contains(_searchQuery);
      }).toList();
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

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
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.grey,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari kupon...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(
                        Icons.search,
                        color: kPrimaryColor,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: _clearSearch,
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),

              // List Kupon
              Expanded(
                child: BlocBuilder<KuponBloc, KuponState>(
                    builder: (context, kuponState) {
                      if (authState is Authenticated && kuponState is KuponInitial) {
                        context.read<KuponBloc>().add(FetchKupon(token: authState.token, userId: authState.id));
                      }

                      if (kuponState is KuponLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (kuponState is KuponLoaded) {
                        final kupons = kuponState.kupons;
                        _filterKupons(kupons);

                        if (_filteredKupons.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isEmpty
                                      ? Icons.card_giftcard
                                      : Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? "Belum Memiliki Kupon"
                                      : "Kupon tidak ditemukan",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isEmpty
                                      ? "Kupon yang Anda dapatkan akan muncul di sini"
                                      : "Coba kata kunci lain",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            if (authState is Authenticated) {
                              context.read<KuponBloc>().add(FetchKupon(token: authState.token, userId: authState.id));
                            }
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            itemCount: _filteredKupons.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final coupon = _filteredKupons[index];
                              return _buildCouponCard(context, coupon);
                            },
                          ),
                        );
                      }

                      if (kuponState is KuponError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Terjadi Kesalahan",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  kuponState.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (authState is Authenticated) {
                                    context.read<KuponBloc>().add(FetchKupon(token: authState.token, userId: authState.id));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Coba Lagi",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildCouponCard(BuildContext context, KuponModel coupon) {
    final isExpired = coupon.kadaluarsa.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isExpired ? Colors.grey.shade200 : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isExpired ? null : () {
          _showCouponBarcode(context, coupon);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpired
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: isExpired ? Colors.grey : Colors.blue,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isExpired ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jenis: ${coupon.hadiah.kategori}',
                      style: TextStyle(
                        color: isExpired ? Colors.grey : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Didapatkan: ${_formatDate(coupon.waktu)}',
                      style: TextStyle(
                        color: isExpired ? Colors.grey : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Kadaluarsa: ${_formatDate(coupon.kadaluarsa)}',
                      style: TextStyle(
                        color: isExpired ? Colors.grey : Colors.red[600],
                        fontSize: 12,
                      ),
                    ),
                    if (isExpired) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'KADALUARSA',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: isExpired ? Colors.grey : null,
              ),
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
              barcode: Barcode.qrCode(),
              data: coupon.kode,
              width: 200,
              height: 200,
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

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat('d MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return DateFormat('d MMMM yyyy').format(date);
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }
}