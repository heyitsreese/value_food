import 'dart:convert';
import 'package:barcode_scanner/scanbot_barcode_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScannerPage extends StatefulWidget {
  final String userId;
  const ScannerPage({super.key, required this.userId});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

Future<void> _initScanbotSdk() async {
  var config = SdkConfiguration(
    licenseKey: "Pg3HoCPubpR3YzQVvcAYvhdta0pkMX" +
                "8/xt47R14irW+oAKPWxHlsbKmXM7KE" +
                "3TdIg9x0KezCVxmXcCjY3Uh2ebOYAF" +
                "hw20/seVMBb7g37q+2LuwFxaFzRmDt" +
                "mnRnQndnonvjEZz3kKEtsv7mDuoVE1" +
                "ek33gk0oa4oa3ihtRVUUyeABrMV+/k" +
                "zuGiLlx+FmThkeQxqGq5Si3CYi0TRx" +
                "4k3wrOcIEgryvE7gTUz1k2oFHgYTVN" +
                "WoWuspYuf/TRhesWbdagI+MEvtrpMp" +
                "667Z/+6u/Z+pq9YExeWgI1CHkE2ISP" +
                "CRdt7T6HDBDguQpPhsXJHLND698V71" +
                "qk/LXpHQtWKQ==\nU2NhbmJvdFNESw" +
                "pjb20uZXhhbXBsZS52YWx1ZV9mb29k" +
                "X2RlbW8KMTc3Nzg1Mjc5OQo4Mzg4Nj" +
                "A3CjE5\n",
    loggingEnabled: true);
  await ScanbotBarcodeSdk.initialize(config);
}

class _ScannerPageState extends State<ScannerPage> {
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _initScanbotSdk().then((_) => _startBarcodeScanning());
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final String jsonString =
        await rootBundle.loadString('assets/products.json');
    setState(() {
      _products = jsonDecode(jsonString);
    });
  }

  Map<String, dynamic>? _findProduct(String barcode) {
    try {
      return _products.firstWhere(
        (p) => p['barcode'] == barcode,
      );
    } catch (_) {
      return null;
    }
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
          child: const Text("Scan Again"),
        ),
      ),
    );
  }

  void _startBarcodeScanning() async {
    var configuration = _rtuUiSingleScanningUseCase();
    var result = await ScanbotBarcodeSdk.barcode.startScanner(configuration);

    if (result is Ok<BarcodeScannerUiResult>) {
      final barcodeValue =
          result.value.items.firstOrNull?.barcode.text ?? '';
          print('Scanned barcode: $barcodeValue');

      if (barcodeValue.isEmpty) return;

      final product = _findProduct(barcodeValue);

      if (!mounted) return;

      if (product != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NutritionFactsPage(product: product),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product not found for barcode: $barcodeValue')),
        );
      }
    }
  }

  BarcodeScannerScreenConfiguration _rtuUiSingleScanningUseCase() {
    var configuration = BarcodeScannerScreenConfiguration();
    var scanningMode = SingleScanningMode();
    scanningMode.confirmationSheetEnabled = false;
    scanningMode.sheetColor = ScanbotColor("#FFFFFF");
    scanningMode.barcodeImageVisible = true;
    scanningMode.barcodeTitle.visible = true;
    scanningMode.barcodeTitle.color = ScanbotColor("#000000");
    scanningMode.barcodeSubtitle.visible = true;
    scanningMode.barcodeSubtitle.color = ScanbotColor("#000000");
    scanningMode.cancelButton.text = "Close";
    scanningMode.cancelButton.foreground.color = ScanbotColor("#C8193C");
    scanningMode.cancelButton.background.fillColor = ScanbotColor("#00000000");
    scanningMode.submitButton.text = "Submit";
    scanningMode.submitButton.foreground.color = ScanbotColor("#FFFFFF");
    scanningMode.submitButton.background.fillColor = ScanbotColor("#C8193C");
    configuration.useCase = scanningMode;
    return configuration;
  }
}

// ─── Nutrition Facts Page ────────────────────────────────────────────────────

class NutritionFactsPage extends StatelessWidget {
  final Map<String, dynamic> product;
  const NutritionFactsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final nutri = product['nutri_facts'] as Map<String, dynamic>;
    final allergens = (product['allergens'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(title: Text(product['product_name'] ?? 'Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            if (product['image_link'] != null)
              Center(
                child: Image.network(
                  product['image_link'],
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 80),
                ),
              ),
            const SizedBox(height: 16),

            // Product name
            Text(
              product['product_name'] ?? '',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Ingredients
            Text(
              'Ingredients',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600),
            ),
            Text(product['description'] ?? '',
                style: const TextStyle(fontSize: 14)),
            const Divider(height: 32, thickness: 2),

            // Nutrition facts label
            const Text(
              'Nutrition Facts',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const Divider(thickness: 8, height: 8),
            _nutriRow('Energy', '${nutri['energy_kcal'] ?? 0} kcal'),
            _nutriRow('Total Fat', '${nutri['fat_g'] ?? 0} g'),
            _nutriRow('  Saturated Fat', '${nutri['saturated_fat_g'] ?? 0} g',
                indent: true),
            _nutriRow('  Trans Fat', '${nutri['trans_fat_g'] ?? 0} g',
                indent: true),
            _nutriRow('Cholesterol', '${nutri['cholesterol_mg'] ?? 0} mg'),
            _nutriRow('Sodium', '${nutri['sodium_mg'] ?? 0} mg'),
            _nutriRow(
                'Total Carbohydrates', '${nutri['carbohydrates_g'] ?? 0} g'),
            _nutriRow('  Dietary Fiber', '${nutri['fiber_g'] ?? 0} g',
                indent: true),
            _nutriRow('  Sugars', '${nutri['sugars_g'] ?? 0} g',
                indent: true),
            _nutriRow('Protein', '${nutri['protein_g'] ?? 0} g'),
            _nutriRow(
                'Calcium',
                '${nutri['calcium_mg'] ?? (nutri['calcium_g'] != null ? nutri['calcium_g'] * 1000 : 0)} mg'),
            _nutriRow(
                'Iron',
                '${nutri['iron_mg'] ?? (nutri['iron_g'] != null ? nutri['iron_g'] * 1000 : 0)} mg'),
            _nutriRow('Potassium', '${nutri['potassium_mg'] ?? 0} mg'),
            const Divider(thickness: 4, height: 16),

            // Allergens
            const SizedBox(height: 8),
            const Text(
              'Allergens',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const Divider(thickness: 8, height: 8),
            if (allergens.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No allergen information available.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allergens
                      .map(
                        (allergen) => Chip(
                          label: Text(
                            allergen,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _nutriRow(String label, String value, {bool indent = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(indent ? 24 : 0, 4, 0, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      indent ? FontWeight.normal : FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}