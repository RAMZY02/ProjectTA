import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // Function to validate barcode (mock implementation)
  bool _isValidBarcode(String barcode) {
    // In a real app, you would check against your database/API
    // Here we just check if it's 12 or 13 digits (common barcode formats)
    final validFormats = RegExp(r'^(\d{12}|\d{13})$');
    return validFormats.hasMatch(barcode);
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

  // Function to show confirmation dialog for valid barcode
  void _showConfirmationDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Text('Apakah Anda yakin ingin menukarkan kupon $barcode dengan hadiah?'),
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
              _processCouponRedemption(barcode);
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
  Future<void> _processCouponRedemption(String barcode) async {
    setState(() => _isProcessing = true);

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

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
              });
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (_isProcessing || !_isScanning) return;

              setState(() {
                _isScanning = false;
                _isProcessing = true;
              });

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) {
                setState(() {
                  _isScanning = true;
                  _isProcessing = false;
                });
                return;
              }

              final String barcode = barcodes.first.rawValue ?? '';
              if (_isValidBarcode(barcode)) {
                _showConfirmationDialog(barcode);
              } else {
                _showInvalidBarcodeDialog();
              }
            },
          ),

          // Processing indicator
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}