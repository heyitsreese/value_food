import 'package:barcode_scanner/scanbot_barcode_sdk.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScannerPage extends StatefulWidget {

  final String userId;

  const ScannerPage({super.key, required this.userId});
  @override
  State<ScannerPage> createState() => _ScannerPageState();
  
}

Future<void>  _initScanbotSdk() async {
  var config = SdkConfiguration(
  licenseKey: "",
  loggingEnabled: true,
);

await ScanbotBarcodeSdk.initialize(config);
}

class _ScannerPageState extends State<ScannerPage> {


  @override
  void initState() {
    super.initState();
     _initScanbotSdk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scanner')),
      body: Center(
        child: ElevatedButton(
          onPressed: _startBarcodeScanning,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text("Start single-barcode scanning"),
        ),
      ),
    );
  }

  void _startBarcodeScanning() async {
      var configuration = BarcodeScannerScreenConfiguration();

  // Start the scanner
  var result = await ScanbotBarcodeSdk.barcode.startScanner(configuration);

  if (result is Ok<BarcodeScannerUiResult>) {
    // TODO: present barcode result as needed
    print(result.value.items.first.barcode.text);
  }
  }
}
