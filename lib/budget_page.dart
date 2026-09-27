import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'profile_page.dart';

import 'dashboard_page.dart';

import 'goals_page.dart';
import 'savings_page.dart';
import 'goals_info_page.dart';
import 'label_page.dart';

class BudgetPage extends StatefulWidget {
  final String userId;
  const BudgetPage({super.key, required this.userId});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  int calories = 0;
  double budget = 0;

  @override
  void initState() {
    super.initState();
    loadBudgetData();
  }

  Future<void> loadBudgetData() async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

    final data = userDoc.data();
    if (data != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: _buildBottomNav(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(color: Color.fromRGBO(122, 184, 77, 100)),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadBudgetData,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 1),
                        _buildButtons(),
                        const SizedBox(height: 20),
                        _buildPlanBox(),
                        const SizedBox(height: 20),
                        _buildMeals(),
                        // const SizedBox(height: 20),
                        // _buildRecommended(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Budget",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "To help manage your spendings",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return SizedBox(
      //color: Colors.white,
      //padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          const SizedBox(width: 15),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2.5,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BudgetPage(userId: widget.userId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 6,
              ),
              child: const Text(
                "Meal Plan",
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2.5,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavingsPage(userId: widget.userId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 6,
              ),
              child: const Text(
                "Savings",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanBox() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // boxShadow: [
        //   BoxShadow(
        //     color: Color.fromRGBO(0, 0, 0, 0.5),
        //     blurRadius: 10,
        //     offset: const Offset(0, 5),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Weight Loss Meal Plan",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          Column(
            children: [
              const Text(
                "Personalized based on your personal info and budget",
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(
                  top: 50,
                  bottom: 50,
                  left: 10,
                  right: 10,
                ),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(196, 35, 35, 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.red,
                      size: 30,
                    ),

                    Text(
                      'Daily Calories',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                        // letterSpacing: 2,
                        // fontFamily: 'Poppins-Bold',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '1920',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        // letterSpacing: 2,
                        // fontFamily: 'Poppins-Bold',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10, width: 30),
              Container(
                padding: const EdgeInsets.only(
                  top: 50,
                  bottom: 50,
                  left: 10,
                  right: 10,
                ),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(136, 185, 103, 0.21),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₱',
                      style: TextStyle(
                        color: Color.fromRGBO(46, 125, 50, 100),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        // letterSpacing: 2,
                        // fontFamily: 'Poppins-Bold',
                      ),
                    ),

                    Text(
                      'Weekly Budget',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                        // letterSpacing: 2,
                        // fontFamily: 'Poppins-Bold',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '₱1000',
                      style: TextStyle(
                        color: Color.fromRGBO(46, 125, 50, 100),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        // letterSpacing: 2,
                        // fontFamily: 'Poppins-Bold',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeals() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Meal Suggestions",
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,

      onTap: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(userId: widget.userId),
            ),
          );
        }

        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BudgetPage(userId: widget.userId),
            ),
          );
        }

        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              //switch
              builder: (_) => LabelPage(userId: widget.userId),
            ),
          );
        }

        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GoalsInfoPage(userId: widget.userId),
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
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner, size: 40),
          label: "",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
      ],
    );
  }
}
