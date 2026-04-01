import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dashboard_page.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

import 'scanner_page.dart';
import 'goals_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String firstName = "";
  String lastName = "";
  int age = 0;
  double height = 0;
  double weight = 0;
  double budget = 0;
  List allergies = [];

  final pesoFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    final data = doc.data();

    if (data != null) {
      setState(() {
        String fullName = data['name'] ?? "";

        firstName = data['firstName'] ?? (fullName.split(" ").isNotEmpty ? fullName.split(" ")[0] : "");
        lastName = data['lastName'] ?? (fullName.split(" ").length > 1 ? fullName.split(" ")[1] : "");
        age = data['age'] ?? 0;
        height = (data['height'] ?? 0).toDouble();
        weight = (data['weight'] ?? 0).toDouble();
        budget = (data['budget'] ?? 0).toDouble();
        allergies = data['allergies'] ?? [];
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  double get bmi {
    if (height == 0) return 0;
    double heightMeters = height * 0.0254;
    return weight / (heightMeters * heightMeters);
  }

  String get bmiLabel {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNav(),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildPersonalInfo(),
                        const SizedBox(height: 20),
                        _buildBMI(),
                        const SizedBox(height: 20),
                        _buildBudget(),
                        const SizedBox(height: 20),
                        _buildAllergies(),

                        // 👇 THIS FILLS REMAINING SPACE NICELY
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile Settings",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Manage your personal information",
              style: TextStyle(color: Color(0xFF1B5E20)),
            ),
          ],
        ),

        // 🔥 LOGOUT BUTTON
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white, size: 28),
          onPressed: () async {
            // Optional confirmation
            bool confirm = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                ) ??
                false;

            if (confirm) {
              logout();
            }
          },
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildPersonalInfo() {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFA5D6A7),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$firstName $lastName",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text("Your health profile"),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(userId: widget.userId),
                    ),
                  );

                  if (result == true) {
                    loadProfile(); // 🔥 refresh data
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit"),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Age\n$age years"),
              Text("Height\n${height.toDouble()}\""),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Weight\n${weight.toInt()} lbs"),
              Text(
                "Budget\n${pesoFormat.format(budget)}",
                style: const TextStyle(fontFamily: 'sans-serif'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBMI() {
    return _card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Body Mass Index (BMI)"),
              const SizedBox(height: 10),
              Text(
                bmi.toStringAsFixed(1),
                style: const TextStyle(fontSize: 32),
              ),
              Text(
                bmiLabel,
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ),
          const Text(
            "Underweight: < 18.5\nNormal: 18.5 - 24.9\nOverweight: 25 - 29.9\nObese: ≥ 30",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBudget() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Grocery Budget"),
          const SizedBox(height: 10),
          Text(
            pesoFormat.format(budget),
            style: const TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const Text("Available per shopping trip"),
        ],
      ),
    );
  }

  Widget _buildAllergies() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Food Allergies",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            children: allergies.map((a) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: Chip(
                  label: Text(a),
                  backgroundColor: Colors.red.shade100,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,   
      showUnselectedLabels: false,

      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(userId: widget.userId),
            ),
          );
        }
        if (index == 2){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScannerPage(userId: widget.userId),
            ),
          );
        }
        if (index==3){
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => GoalsPage(userId: widget.userId),
            ),
          );
        }
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.savings), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
      ],
    );
  }
}