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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF81C784),
              Color(0xFFE8F5E9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔙 HEADER
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Add Expense",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔥 CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Expense Type",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      const SizedBox(height: 8),

                      // 🔽 DROPDOWN
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedType,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: "Food", child: Text("Food")),
                              DropdownMenuItem(value: "Grocery", child: Text("Grocery")),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Amount",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      const SizedBox(height: 8),

                      // 💸 AMOUNT FIELD
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "₱000.00",

                          // 👇 THIS styles the hint text
                          hintStyle: TextStyle(
                            fontFamily: 'sans-serif'
                          ),

                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ✅ ADD BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: addTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF88B967),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: const Text(
                            "Add",
                            style: TextStyle(
                              fontSize: 15, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}