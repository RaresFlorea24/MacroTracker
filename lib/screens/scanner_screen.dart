import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
//documentation: https://pub.dev/packages/mobile_scanner/example

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a barcode')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_done) return;
          final code = capture.barcodes.first.rawValue; //getting the first barcode from the list of barcodes detected
          if (code == null) return;
          _done = true;
          Navigator.of(context).pop(code);
        },
      ),
    );
  }
}