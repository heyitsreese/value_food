import 'package:barcode_scanner/scanbot_barcode_sdk.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ScannerPage extends StatefulWidget {
  final String userId;

  const ScannerPage({super.key, required this.userId});
  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

Future<void> _initScanbotSdk() async {
  var config = SdkConfiguration(licenseKey: "", loggingEnabled: true);

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
    var configuration = rtuUiSingleScanningUseCase();

    // Start the scanner
    // var result = await ScanbotBarcodeSdk.barcode.startScanner(
    // BarcodeScannerScreenConfiguration(),
    var result = await ScanbotBarcodeSdk.barcode.startScanner(configuration);

    if (result is Ok<BarcodeScannerUiResult>) {
      //ScanbotAlertDialog();
    }

  
  }


  BarcodeScannerScreenConfiguration rtuUiSingleScanningUseCase() {
    // Create the default configuration object.
    var configuration = BarcodeScannerScreenConfiguration();

    // Initialize the use case for single scanning.
    var scanningMode = SingleScanningMode();
    // Enable and configure the confirmation sheet.
    scanningMode.confirmationSheetEnabled = true;
    scanningMode.sheetColor = ScanbotColor("#FFFFFF");

    // Hide/unhide the barcode image.
    scanningMode.barcodeImageVisible = true;

    // Configure the barcode title of the confirmation sheet.
    scanningMode.barcodeTitle.visible = true;
    scanningMode.barcodeTitle.color = ScanbotColor("#000000");

    // Configure the barcode subtitle of the confirmation sheet.
    scanningMode.barcodeSubtitle.visible = true;
    scanningMode.barcodeSubtitle.color = ScanbotColor("#000000");

    // Configure the cancel button of the confirmation sheet.
    scanningMode.cancelButton.text = "Close";
    scanningMode.cancelButton.foreground.color = ScanbotColor("#C8193C");
    scanningMode.cancelButton.background.fillColor = ScanbotColor("#00000000");

    // Configure the submit button of the confirmation sheet.
    scanningMode.submitButton.text = "Submit";
    scanningMode.submitButton.foreground.color = ScanbotColor("#FFFFFF");
    scanningMode.submitButton.background.fillColor = ScanbotColor("#C8193C");

    // Configure other parameters, pertaining to single-scanning mode as needed.

    configuration.useCase = scanningMode;

    // Configure other parameters as needed.

    return configuration;
  }

  Future<List<dynamic>> handleScanningResultWithDataParsers(
    BuildContext context) async {
  // Start the barcode RTU UI with default configuration
  final scanningResult = await ScanbotBarcodeSdk.barcode.startScanner(
    BarcodeScannerScreenConfiguration(),
  );

  // Check if the status returned is ok and that the data is present
  if (scanningResult is Ok<BarcodeScannerUiResult>) {
    final items = scanningResult.value.items;
    final parsedData = <dynamic>[];

    // Loop through the scanned barcode items and extract the desired barcode data
    for (final item in items) {
      final genericDocument = item.barcode.extractedDocument;
      if (genericDocument == null) continue;

      final typeName = genericDocument.type.name;

      switch (typeName) {

        case GS1.DOCUMENT_TYPE:
          final gs1Elements = GS1(genericDocument).elements;
          parsedData.add(gs1Elements.isNotEmpty
              ? gs1Elements.first.applicationIdentifier
              : null);
          break;
      }
    }

    return parsedData;
  } else {
    // await showAlertDialog(context, title: "Info", scanningResult.toString());
  }

  return [];
}
}

