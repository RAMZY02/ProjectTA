import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/kupon/kupon_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_event.dart';
import 'package:project_ta/bloc/kupon/kupon_state.dart';

class ScanBarcodeScreen extends StatefulWidget {
  const ScanBarcodeScreen({super.key});

  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  bool _torchEnabled = false;
  CameraFacing _cameraFacing = CameraFacing.back;
  int selectedKupon = 0;
  String namaHadiah = '';

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // Function to validate barcode (mock implementation)
  Future<bool> _isValidBarcode(String barcode, AuthState state) async {
    bool valid = false;
    final kuponBloc = context.read<KuponBloc>();
    var kuponState = kuponBloc.state;

    if (state is Authenticated) {
      // Trigger fetch data
      kuponBloc.add(FetchAllKupon(token: state.token));

      // Tunggu sampai state berubah menjadi KuponLoaded
      await for (final state in kuponBloc.stream) {
        if (state is KuponLoaded) {
          kuponState = state;
          break;
        }
      }
    }

    if (kuponState is KuponLoaded) {
      for (final kupon in kuponState.kupons) {
        if (kupon.kode == barcode) {
          valid = true;
          selectedKupon = kupon.id;
          namaHadiah = kupon.hadiah.nama;
          break;
        }
      }
    }

    return valid;
  }

  Future<bool> _isClaimed(int idKupon, AuthState state) async {
    print("ini id kupon $idKupon");
    bool claimed = false;
    final kuponState = context.read<KuponBloc>().state;

    print("kupon state $kuponState");
    if(kuponState is KuponLoaded){
      print("ini status kupon ${kuponState.kupons[idKupon-1].status}");
      if(kuponState.kupons[idKupon-1].status == 'claimed'){
        claimed = true;
      }
    }

    return claimed;
  }

  Future<bool> _isExpired(int idKupon, AuthState state) async {
    print("ini id kupon $idKupon");
    bool expired = false;
    final kuponState = context.read<KuponBloc>().state;

    print("kupon state $kuponState");
    if(kuponState is KuponLoaded){
      print("ini status kupon ${kuponState.kupons[idKupon-1].status}");
      if(kuponState.kupons[idKupon-1].kadaluarsa.isBefore(DateTime.now())){
        expired = true;
      }
    }

    return expired;
  }

  // Function to show invalid barcode dialog
  void _showInvalidBarcodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barcode Tidak Valid'),
        content: const Text('Barcode yang discan tidak valid atau tidak terdaftar.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
                _isProcessing = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClaimedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barcode Sudah Diclaim'),
        content: const Text('Barcode yang discan sudah diclaim sebelumnya.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
                _isProcessing = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barcode Sudah Kadaluarsa'),
        content: const Text('Barcode yang discan sudah melewati batas tanggal pemakaiannya.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
                _isProcessing = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function to show confirmation dialog for valid barcode
  void _showConfirmationDialog(String barcode, String token, int idKupon, String namaHadiah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Text('Apakah Anda yakin ingin menukarkan kupon dengan hadiah $namaHadiah?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
                _isProcessing = false;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you would typically call your API to redeem the coupon
              _processCouponRedemption(barcode, token, idKupon);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Yakin'),
          ),
        ],
      ),
    );
  }

  // Mock function to process coupon redemption
  Future<void> _processCouponRedemption(String barcode, String token, int idKupon) async {
    setState(() => _isProcessing = true);

    context.read<KuponBloc>().add(ClaimKupon(token: token, idKupon: idKupon));

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kupon $barcode berhasil ditukarkan!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _isProcessing = false;
      _isScanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: _torchEnabled ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _torchEnabled = !_torchEnabled;
              });
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: Icon(
              _cameraFacing == CameraFacing.front
                  ? Icons.camera_front
                  : Icons.camera_rear,
            ),
            onPressed: () {
              setState(() {
                _cameraFacing = _cameraFacing == CameraFacing.front
                    ? CameraFacing.back
                    : CameraFacing.front;
                _torchEnabled = false;
              });
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner camera
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (_isProcessing || !_isScanning) return;

              setState(() {
                _isScanning = false;
                _isProcessing = true;
              });

              final List<Barcode> barcodes = capture.barcodes;
              print(barcodes);
              if (barcodes.isEmpty) {
                setState(() {
                  _isScanning = true;
                  _isProcessing = false;
                });
                return;
              }

              final String barcode = barcodes.first.rawValue ?? '';
              if (await _isValidBarcode(barcode, authState)) {
                if(await _isClaimed(selectedKupon, authState)){
                  _showClaimedDialog();
                }
                else if(await _isExpired(selectedKupon, authState)){
                  _showExpiredDialog();
                }
                else if(authState is Authenticated){
                  _showConfirmationDialog(barcode, authState.token, selectedKupon, namaHadiah);
                }
              } else {
                _showInvalidBarcodeDialog();
              }
            },
          ),

          // Processing indicator dengan backdrop semi-transparan
          if (_isProcessing)
            Container(
              color: Colors.black54, // Backdrop semi-transparan
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memproses barcode...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}