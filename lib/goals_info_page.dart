import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'profile_page.dart';

import 'dashboard_page.dart';

import 'goals_page.dart';
import 'budget_page.dart';

class GoalsInfoPage extends StatefulWidget {
  final String userId;
  const GoalsInfoPage({super.key, required this.userId});

  @override
  State<GoalsInfoPage> createState() => _GoalsInfoPageState();
}

class _GoalsInfoPageState extends State<GoalsInfoPage> {
  double weight = 0;
  double targetWeight = 0;
  String targetDate = "";

  @override
  void initState() {
    super.initState();
    loadGoalsData();
  }

  Future<void> loadGoalsData() async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

    final data = userDoc.data();
    if (data != null) {
      setState(() {
        weight = (data['weight'] ?? 0).toDouble();
        targetWeight = (data['targetWeight'] ?? 0).toDouble();
        targetDate = (data['targetDate']);
      });
    } 
  }

  double get progress => weight == 0 ? 0 : targetWeight / weight;
  double get progressPercent => (progress * 100).roundToDouble();
  double get toLose => weight - targetWeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNav(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFFE8F5E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadGoalsData,
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
                          _buildGoalCard(),
                          const SizedBox(height: 20),
                          _buildTimeline(),
                          const SizedBox(height: 20),
                          _buildRecommended(),
                        ],
                      ),
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

  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.all(40),
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
        children: [
          Row(
            children: [
              const Text(
                "Your goal",
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 100),

              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GoalsPage(userId: widget.userId),
                    ),
                  );

                  if (result == true) {
                    loadGoalsData();
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(0.1),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 227, 225, 225),
                  // borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Current Weight: \n $weight lbs', //test
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),

              const SizedBox(height: 10, width: 50),
              Container(
                padding: const EdgeInsets.all(0.1),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 227, 225, 225),
                  // borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Target Weight: \n $targetWeight lbs', //test
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Text("Progress"),
              const SizedBox(width: 170),
              Text('$progressPercent %'),
            ],
          ),

          const SizedBox(height: 10),
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 20,
                backgroundColor: Colors.grey.shade300,
                color: Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 10),
          Text(
            '$toLose lbs to lose', //test
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
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
        children: [
          Row(
            children: [
              Text(
                "Timeline",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Target Date",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,

                  color: Colors.black,
                ),
              ),

              const SizedBox(width: 80),
              Text(
                "05/20/2026",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,

                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Days Remaining",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,

                  color: Colors.black,
                ),
              ),

              const SizedBox(width: 80),
              Text(
                "60 days",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,

                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommended() {
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
        children: [
          Row(
            children: [
              Text(
                "Recommended Plan",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Weekly target",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 227, 225, 225),
                  // borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  '1.2 lbs/ week \n This is healthy and sustainable ', //test
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
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
      currentIndex: 3,
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

         if (index == 1){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BudgetPage(userId: widget.userId),
            ),
          );
        }

        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              // switch
              builder: (_) => BudgetPage(userId: widget.userId),
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
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner, size: 40), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
      ],
    );
  }
}
