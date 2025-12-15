import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Group QR Code'),
      ),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: (capture) {
          if (_isProcessing) return;
          setState(() {
            _isProcessing = true;
          });

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? scannedGroupId = barcodes.first.rawValue;
            if (scannedGroupId != null && scannedGroupId.isNotEmpty) {
              _joinGroup(scannedGroupId);
            }
          }
        },
      ),
    );
  }

  Future<void> _joinGroup(String groupId) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showError('You must be logged in to join a group.');
      return;
    }

    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    await dbRef.child('groups/$groupId/members/${currentUser.uid}').set(true);
    await dbRef.child('users/${currentUser.uid}/groups/$groupId').set(true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined group!')),
      );
      Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}
