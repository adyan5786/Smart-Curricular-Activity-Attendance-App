import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class StudentQRScannerScreen extends StatefulWidget {
  final void Function(String qrData) onScan;
  const StudentQRScannerScreen({super.key, required this.onScan});

  @override
  State<StudentQRScannerScreen> createState() => _StudentQRScannerScreenState();
}

class _StudentQRScannerScreenState extends State<StudentQRScannerScreen> {
  bool _scanned = false;

  void _handleBarcode(BarcodeCapture capture) {
    if (_scanned) return; // Prevent duplicate scans
    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final String? raw = barcode?.rawValue;
    if (raw != null && raw.isNotEmpty) {
      _scanned = true;
      widget.onScan(raw);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Attendance QR')),
      body: MobileScanner(
        onDetect: _handleBarcode,
      ),
    );
  }
}