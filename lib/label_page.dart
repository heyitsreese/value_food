import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RecognizeResult {
  final String imagePath;
  final String text;
  RecognizeResult(this.imagePath, this.text);
}

class LabelPage extends StatefulWidget {
  final String userId;

  const LabelPage({super.key, required this.userId});

  @override
  State<LabelPage> createState() => _LabelPageState();
}

class _LabelPageState extends State<LabelPage> {
  //File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  String _recognizedText = '';
  XFile? _imageFile;
  bool _isProcessing = false;
  File? selectedImage;

  //serving Info is the header, the first 4 lines of a nutritional label starting from Nutrition
  var _servingInfo;
  var servingRegex = RegExp(r'\Nutrition(.*\n){4}', caseSensitive: false);

  // calories + the amount , add separate regex for calories num
  var _caloriesInfo;
  var caloriesRegex = RegExp(
    r'\Calories \d+|Calories \Wkcal\W \d+',
    caseSensitive: false,
  );

  // for the fat number, no g at the end for now, can just change the d to n if need the g too. Also sometimes 0 is read as the letter O. for future purposes we can
  //probably use if statement for if this regex gets the letter O, that means its 0.
  var _fatNum;
  var fatNumRegex = RegExp(
    r'(?<=Total Fat)(.*\d)|(?<=Total Fat)(.*O)',
    caseSensitive: false,
  );

  // saturated fat
  var _satFatNum;
  var satFatNumRegex = RegExp(
    r'(?<=Saturated Fat)(.*\d)|(?<=Saturated Fat)(.*O)',
    caseSensitive: false,
  );

  // trans fat
  var _transFatNum;
  var transFatNumRegex = RegExp(
    r'(?<=Trans Fat)(.*\d)|(?<=Trans Fat)(.*O)',
    caseSensitive: false,
  );

  // cholesterol num
  var _cholesterolNum;
  var cholesterolNumRegex = RegExp(
    r'(?<=Cholesterol)(.*\d)|(?<=Cholesterol)(.*O)',
    caseSensitive: false,
  );

  //sodium num
  var _sodiumNum;
  var sodiumNumRegex = RegExp(
    r'(?<=Sodium)(.*\d)|(?<=Sodium)(.*O)',
    caseSensitive: false,
  );

  // potassium
  var _potassiumNum;
  var potassiumNumRegex = RegExp(
    r'(?<=Potassium)(.*\d)|(?<=Potassium)(.*O)',
    caseSensitive: false,
  );

  // total carbohydrate value
  var _totalCarbNum;
  var totalCarbNumRegex = RegExp(
    r'(?<=Total Carbohydrate)(.*\d)|(?<=Total Carbohydrate)(.*O)',
    caseSensitive: false,
  );

  //dietary fiber num
  var _dietaryfiberNum = 'r';
  var dietaryFiberNumRegex = RegExp(
    r'(?<=Dietary Fiber)(.*\d)|(?<=Dietary Fiber)(.*O)|(?<=Dletary Fiber)',
    caseSensitive: false,
  );

  // sugars/ total sugars
  var _sugars;
  var sugarsRegex = RegExp(r'\Sugars|Total Sugars', caseSensitive: false);

  var _sugarsNum;
  var sugarsNumRegex = RegExp(
    r'(?<=Sugars)(.*\d)|(?<=Sugars)(.*O)|(?<=Total Sugars)(.*\d)|(?<=Total Sugars)(.*O)',
    caseSensitive: false,
  );

  // protein / total protein
  var _protein;
  var proteinRegex = RegExp(r'\Protein|Total Protein', caseSensitive: false);

  var _proteinNum;
  var proteinNumRegex = RegExp(
    r'(?<=Protein)(.*\d)|(?<=Protein)(.*O)|(?<=Total Protein)(.*\d)|(?<=Total Protein)(.*O)',
    caseSensitive: false,
  );

  // Philippines uses RENI on nutritional labels but some use Daily Value % too and some also have both RENI and DV%
  // regex to find text that starts with digit(s) or '<' and has percentage next to it
  //var reniRegex = RegExp(r'\.*^\d+%|\.*^<\d+%', caseSensitive: false);
  //for now using this regex for testing since other one wasnt working
  var reniRegex = RegExp(r'\d+%', caseSensitive: false);

  // putting all matches of reniRegex in a list
  var reniList;

  // for the reni percentage of nutrients
  var _caloriesReni;
  var _dietaryFiberReni;
  var _proteinReni;

  var _fatReni;
  var _satFatReni;
  var _cholesterolReni;
  var _sodiumReni;
  var _totalCarbReni;

  // Daily Value
  // var DVList;
  // var _fatDV;
  // var _satFatDV;
  // var _cholesterolDV;
  // var _sodiumDV;
  // var _totalCarbDV;
  // var _dietaryFiberDV;
  //var DVRegex = RegExp(r'\.*^\d+%|\.*^<\d+%', caseSensitive: false);
  // var DVRegex = RegExp(r'\d+%', caseSensitive: false);

// for when calories number is on the very right 
  var caloriesRegex2 = RegExp(r'(?<=[^\w ])\d+(?=\n)', caseSensitive: false);
  var _caloriesTest;

  @override
  void initState() {
    super.initState();
    loadLabelData();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isProcessing = true;
        _recognizedText = '';
      });

      final XFile? pickedFile = await _picker
          .pickImage(source: source, maxWidth: 2048, imageQuality: 85)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              debugPrint('[picker] pickImage timed out after 20s');
              return null;
            },
          );
      debugPrint('[picker] pickImage returned: ${pickedFile?.path}');

      if (pickedFile == null) return;

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      setState(() {
        _imageFile = pickedFile;
        _recognizedText = recognizedText.text;
        print(recognizedText.text);

        //checking for regex match
        var servingMatch = servingRegex.firstMatch(_recognizedText);
        var caloriesMatch = caloriesRegex.firstMatch(_recognizedText);
        var caloriesMatch2 = caloriesRegex2.firstMatch(_recognizedText);
        var fatNumMatch = fatNumRegex.firstMatch(_recognizedText);
        var satFatNumMatch = satFatNumRegex.firstMatch(_recognizedText);
        var transFatNumMatch = transFatNumRegex.firstMatch(_recognizedText);
        var cholesterolNumMatch = cholesterolNumRegex.firstMatch(
          _recognizedText,
        );
        var sodiumNumMatch = sodiumNumRegex.firstMatch(_recognizedText);
        var potassiumNumMatch = potassiumNumRegex.firstMatch(_recognizedText);
        var totalCarbNumMatch = totalCarbNumRegex.firstMatch(_recognizedText);
        var dietaryFiberNumMatch = dietaryFiberNumRegex.firstMatch(
          _recognizedText,
        );
        var sugarsMatch = sugarsRegex.firstMatch(_recognizedText);
        var sugarsNumMatch = sugarsNumRegex.firstMatch(_recognizedText);
        var proteinMatch = proteinRegex.firstMatch(_recognizedText);
        var proteinNumMatch = proteinNumRegex.firstMatch(_recognizedText);

        // reni stuff
        reniList =
            reniRegex
                .allMatches(_recognizedText)
                .map((z) => z.group(0))
                .toList();
        print(reniList);

        var lowercaseLabel = _recognizedText.toLowerCase();

        // check if label uses RENI or DV 
        if (lowercaseLabel.contains('daily value') || _recognizedText.contains('dv')) {
          print('Daily Value Label');
          // daily value labels usually have value for all except trans fat, sugars , and protein
          // labels also usually have 9-10 percentages, besides total fat, sat fat, cholesterol, sodium, total card, dietary fiber theres vitamin A, potassium
          if (reniList.length >= 6) {
            _fatReni = reniList[0];
            _satFatReni = reniList[1];
            _cholesterolReni = reniList[2];
            _sodiumReni = reniList[3];
            _totalCarbReni = reniList[4];
            _dietaryFiberReni = reniList[5];
            //reni only values
            _caloriesReni = '';
            _proteinReni = '';
            //
          } else {
            _fatReni = '';
            _satFatReni = '';
            _cholesterolReni = '';
            _sodiumReni = '';
            _totalCarbReni = '';
            _dietaryFiberReni = '';
            //reni only values
            _caloriesReni = '';
            _proteinReni = '';
            //
          }
          // if its RENI label
           // for now we can assume if the nutrition label has 2 percentages for the RENI, it will be for these nutrient values.
           //however some labels with 2 percentages has one for energy instead of calories
           // for juices its usually reni % for Calories, Dietary Fiber, Protein and others like Vitamin A
        } else {
          if (reniList.length == 2) {

            _caloriesReni = reniList[0];
            _proteinReni = reniList[1];
            _dietaryFiberReni = '';

            _fatReni = ' ';
            _satFatReni = '';
            _cholesterolReni = '';
            _sodiumReni = '';
            _totalCarbReni = '';

          } else if (reniList.length == 3) {
            _caloriesReni = reniList[0];
            _dietaryFiberReni = reniList[1];
            _proteinReni = reniList[2];

             _fatReni = ' ';
            _satFatReni = '';
            _cholesterolReni = '';
            _sodiumReni = '';
            _totalCarbReni = '';
         
          } else if (reniList.length == 6) {
            _caloriesReni = reniList[0];
            _dietaryFiberReni = reniList[1];
            _proteinReni = reniList[2];

            _fatReni = ' ';
            _satFatReni = '';
            _cholesterolReni = '';
            _sodiumReni = '';
            _totalCarbReni = '';
           
          } else {
            _caloriesReni = 'work in progress';
            _dietaryFiberReni = '';
            _proteinReni = '';

            _fatReni = ' ';
            _satFatReni = '';
            _cholesterolReni = '';
            _sodiumReni = '';
            _totalCarbReni = '';
            _dietaryFiberReni = '';
          }
        }

        // check regex match
        _servingInfo =
            servingMatch?.group(0) ?? 'Not recognized as Nutritional Label';
        _caloriesInfo = caloriesMatch?.group(0) ?? 'Calories ${caloriesMatch2?.group(0)}' ?? ' ';
        //_caloriesTest = caloriesMatch2?.group(0) ??'';
        print('test calories');
        _fatNum = fatNumMatch?.group(0) ?? '';
        _satFatNum = satFatNumMatch?.group(0) ?? '';
        _transFatNum = transFatNumMatch?.group(0) ?? '';  
        _cholesterolNum = cholesterolNumMatch?.group(0) ?? '';
        _sodiumNum = sodiumNumMatch?.group(0) ?? '';
        _potassiumNum = potassiumNumMatch?.group(0) ?? '';
        _totalCarbNum = totalCarbNumMatch?.group(0) ?? '';
        _dietaryfiberNum = dietaryFiberNumMatch?.group(0) ?? '';
        _sugars = sugarsMatch?.group(0) ?? 'Sugars';
        _sugarsNum = sugarsNumMatch?.group(0) ?? '';
        _protein = proteinMatch?.group(0) ?? 'Protein';
        _proteinNum = proteinNumMatch?.group(0) ?? '';

        // testing
        _caloriesInfo?.split(" ").forEach((word) {
          if (word == 'Energy') {
            print("checking if label has energy instead of calories");
          }
        });


      });
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> loadLabelData() async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

    final data = userDoc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Nutrtion Facts Label')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFFE8F5E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// scanner options
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                /// upload image
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick Image'),
                ),

                /// take photo
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Use Camera'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _isProcessing
                      ? const Center(
                        child: CircularProgressIndicator.adaptive(),
                      )
                      : _imageFile == null
                      ? const Center(child: Text('No image selected'))
                      : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.file(File(_imageFile!.path)),
                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(12),
                              color: Colors.white,
                              child: Text(
                                _recognizedText.isEmpty
                                    ? 'No text recognized.'
                                    // to see the full text
                                    //: _recognizedText,
                                    // text with regex, serving and calories info on top of table
                                    : _servingInfo +
                                        ('\n') +
                                        (_caloriesInfo ?? ' ') +
                                        ('\n'),

                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                            // where table begins
                            SingleChildScrollView(
                              child: Table(
                                border: TableBorder.all(
                                  color: const Color.fromARGB(
                                    255,
                                    143,
                                    210,
                                    67,
                                  ),
                                ),
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  const TableRow(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 143, 210, 67),
                                    ),
                                    children: [
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),

                                          child: Text(
                                            'Nutrient',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            '% RENI / % DV',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // the rows below the Nutrient and RENI
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: _caloriesInfo ?? ' ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _caloriesReni,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(),
                                      ),
                                    ],
                                  ),

                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ('Total Fat'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            // sometimes the ocr reads 0 as O
                                            TextSpan(text: _fatNum.replaceAll('O', '0')),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _fatReni ?? ' ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(),
                                      ),
                                    ],
                                  ),

                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      Text(
                                        ('Saturated Fat') + (_satFatNum.replaceAll('O', '0')),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(),
                                      ),
                                      Text(
                                        _satFatReni ?? ' ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(),
                                      ),
                                    ],
                                  ),

                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      Text(
                                        ('Trans Fat') + (_transFatNum.replaceAll('O', '0')),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(),
                                      ),
                                      Text(
                                        ' ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(),
                                      ),
                                    ],
                                  ),

                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ('Cholesterol'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: _cholesterolNum.replaceAll('O', '0')),
                                          ],
                                        ),
                                      ),
                                      Text(_cholesterolReni ?? ' ', textAlign: TextAlign.center),
                                    ],
                                  ),

                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ('Sodium'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: _sodiumNum.replaceAll('O', '0')),
                                          ],
                                        ),
                                      ),
                                      Text(_sodiumReni ?? ' ', textAlign: TextAlign.center),
                                    ],
                                  ),

                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: 'Potassium',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: _potassiumNum.replaceAll('O', '0')),
                                          ],
                                        ),
                                      ),
                                      Text(' ', textAlign: TextAlign.center),
                                    ],
                                  ),

                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: 'Total Carbs',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: _totalCarbNum.replaceAll('O', '0')),
                                          ],
                                        ),
                                      ),
                                      Text(_totalCarbReni ?? ' ', textAlign: TextAlign.center),
                                    ],
                                  ),

                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      Text(
                                        ('Dietary Fiber ') + _dietaryfiberNum.replaceAll('O', '0'),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        _dietaryFiberReni ?? ' ',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),

                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(text: _sugars),
                                            TextSpan(text: _sugarsNum.replaceAll('O', '0')),
                                          ],
                                        ),
                                      ),
                                      Text(' ', textAlign: TextAlign.center),
                                    ],
                                  ),

                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: _protein,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: _proteinNum.replaceAll('O', '0')),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _proteinReni ?? '',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),
                            const SizedBox(height: 52),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
