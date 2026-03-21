import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart';

class GetInfoPage extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;

  const GetInfoPage({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<GetInfoPage> createState() => _GetInfoPageState();
}

class _GetInfoPageState extends State<GetInfoPage> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final budgetController = TextEditingController();
  final allergyController = TextEditingController();

  List<String> allergies = [];

  Future<void> saveUserData() async {
    try {
      if (allergyController.text.isNotEmpty) {
        allergies.add(allergyController.text.trim());
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'name': "${widget.firstName} ${widget.lastName}",
        'age': int.tryParse(ageController.text) ?? 0,
        'height': int.tryParse(heightController.text) ?? 0,
        'weight': int.tryParse(weightController.text) ?? 0,
        'budget': double.tryParse(budgetController.text) ?? 0,
        'spent': 0,
        'allergies': allergies,
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(userId: widget.userId),
        ),
      );
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  void addAllergy() {
    if (allergyController.text.isNotEmpty) {
      setState(() {
        allergies.add(allergyController.text.trim());
        allergyController.clear();
      });
    }
  }

  void removeAllergy(String item) {
    setState(() {
      allergies.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFA5D6A7),
              Color(0xFFE8F5E9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF81C784),
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Create Profile",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Enter your personal information"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildField("Age", ageController),
                  _buildField("Height (inches)", heightController),
                  _buildField("Weight (lbs)", weightController),
                  _buildField("Available budget (php)", budgetController),

                  const SizedBox(height: 10),

                  const Text("Food Allergies"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: allergyController,
                          decoration: const InputDecoration(
                            hintText: "e.g. peanuts, dairy",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: addAllergy,
                      )
                    ],
                  ),

                  Wrap(
                    children: allergies.map((item) {
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: Chip(
                          label: Text(item),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => removeAllergy(item),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF81C784),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}