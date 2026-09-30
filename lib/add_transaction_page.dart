import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransactionPage extends StatefulWidget {
  final String userId;

  const AddTransactionPage({super.key, required this.userId});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  String selectedType = "Lunch";
  final amountController = TextEditingController();

  Future<void> addTransaction() async {
    double amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) return;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId);

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
    await userRef.update({'spent': currentSpent + amount});

    if (!mounted) return;
    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Add Expense", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Color.fromRGBO(122, 184, 77, 100),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Color.fromRGBO(122, 184, 77, 100)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          // child: Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: Container(
                // alignment: Alignment.center,
                // color: Colors.white,
                width: MediaQuery.of(context).size.width / 1.2,
                height: MediaQuery.of(context).size.height / 2.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expense Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 5),
                      Container(
                        color: const Color.fromRGBO(235, 235, 235, 100),
                        child: DropdownButtonFormField(
                          value: selectedType,
                          items: const [
                            DropdownMenuItem(
                              value: "Lunch",
                              child: Text("Lunch"),
                            ),
                            DropdownMenuItem(
                              value: "Dinner",
                              child: Text("Dinner"),
                            ),
                            DropdownMenuItem(
                              value: "Grocery",
                              child: Text("Grocery"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                          decoration: const InputDecoration(labelText: "Type"),
                        ),
                      ),
                      const SizedBox(height: 60),

                      Text(
                        'Amount ₱',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 5),
                      Container(
                        color: const Color.fromRGBO(235, 235, 235, 100),
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Amount",
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.3,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: addTransaction,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 6,
                          ),
                          child: Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ),
          ),
        ),
      ),
    );
  }
}
