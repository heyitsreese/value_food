import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final budgetController = TextEditingController();
  final allergyController = TextEditingController();

  List<String> allergies = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    final data = doc.data();

    if (data != null) {
      firstNameController.text = data['firstName'] ?? "";
      lastNameController.text = data['lastName'] ?? "";
      ageController.text = data['age'].toString();
      heightController.text = data['height'].toString();
      weightController.text = data['weight'].toString();
      budgetController.text = data['budget'].toString();
      allergies = List<String>.from(data['allergies'] ?? []);
      setState(() {});
    }
  }

  Future<void> saveChanges() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'name':
          "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
      'age': int.tryParse(ageController.text) ?? 0,
      'height': int.tryParse(heightController.text) ?? 0,
      'weight': int.tryParse(weightController.text) ?? 0,
      'budget': double.tryParse(budgetController.text) ?? 0,
      'allergies': allergies,
    });

    if (!mounted) return;

    Navigator.pop(context, true); // 👈 return success
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

  Widget field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            field("First Name", firstNameController),
            field("Last Name", lastNameController),
            field("Age", ageController),
            field("Height", heightController),
            field("Weight", weightController),
            field("Budget", budgetController),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: allergyController,
                    decoration: const InputDecoration(
                      hintText: "Add allergy",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addAllergy,
                )
              ],
            ),

            Wrap(
              children: allergies.map((a) {
                return Chip(
                  label: Text(a),
                  onDeleted: () => removeAllergy(a),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveChanges,
              child: const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }
}