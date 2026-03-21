import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransactionPage extends StatefulWidget {
  final String userId;

  const AddTransactionPage({super.key, required this.userId});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  String selectedType = "Food";
  final amountController = TextEditingController();

  Future<void> addTransaction() async {
    double amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);

    final userDoc = await userRef.get();
    final data = userDoc.data();

    double currentSpent = (data?['spent'] ?? 0).toDouble();

    // 🔥 ADD TRANSACTION
    await userRef.collection('transactions').add({
      'type': selectedType,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 🔥 UPDATE TOTAL SPENT
    await userRef.update({
      'spent': currentSpent + amount,
    });

    if (!mounted) return;
    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField(
              value: selectedType,
              items: const [
                DropdownMenuItem(value: "Food", child: Text("Food")),
                DropdownMenuItem(value: "Grocery", child: Text("Grocery")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              decoration: const InputDecoration(labelText: "Type"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: addTransaction,
              child: const Text("Add"),
            )
          ],
        ),
      ),
    );
  }
}