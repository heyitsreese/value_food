import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'profile_page.dart';
import 'add_transaction_page.dart';

import 'dashboard_page.dart';
import 'scanner_page.dart';

class GoalsPage extends StatefulWidget {
  final String userId;

  const GoalsPage({super.key, required this.userId});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  double weight = 0;

  double desiredWeight = 0;
  String targetDate = "DD/MM/YYYY";

  @override
  void initState() {
    super.initState();
    loadGoalsData();
  }

  Future<void> loadGoalsData() async {}

  Future<void> saveGoal() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNav(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA5D6A7), Color(0xFFE8F5E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          // onRefresh: loadDashboardData,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildGoalsCard(),
                        const SizedBox(height: 20),
                        // _buildRecentActivity(),
                        // const SizedBox(height: 20),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Weight Goal",
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Track your progress towards your target",
          style: TextStyle(fontSize: 16, color: Color(0xFF33691E)),
        ),
      ],
    );
  }

  Widget _buildGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Set your weight goal",
            style: TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(0, 0, 0, 1),
              fontWeight: FontWeight.bold
            ),
          ),

          // current weight box
          const SizedBox(height: 10, width: 100),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 227, 225, 225),
              // borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Current Weight: \n 150 lbs', //test
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            )

          ),

          const SizedBox(height: 20),
          const Text(
            "Desired Weight (lbs)",
            style: TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(0, 0, 0, 1),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10, width: 50),
          // desired weight box
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(255, 227, 225, 225),
              labelText: 'Enter desired weight',
              labelStyle: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 1),
                fontFamily: 'Poppins',
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Target Date",
            style: TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(0, 0, 0, 1),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10, width: 50),
          // desired weight box
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(255, 227, 225, 225),
              labelText: 'dd/mm/yyyy',
              labelStyle: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 1),
                fontFamily: 'Poppins',
              ),
            ),
          ),

          /// end
          const SizedBox(height: 40),
          // button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88B967),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              onPressed: saveGoal,
              child: const Text(
                "Save Goal",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 3,
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
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScannerPage(userId: widget.userId),
            ),
          );
        }

         if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilePage(userId: widget.userId),
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
