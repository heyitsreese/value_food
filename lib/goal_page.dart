import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';

class GoalPage extends StatefulWidget {
  final String userId;
  const GoalPage({super.key, required this.userId});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  double? currentWeight;
  double? targetWeight;
  DateTime? targetDate;

  bool get hasGoal => targetWeight != null && targetDate != null;

  double get progress {
    if (!hasGoal || currentWeight == null) return 0;

    double totalLoss = currentWeight! - targetWeight!;
    double currentLoss = 0; // future: real tracking

    return totalLoss <= 0 ? 0 : (currentLoss / totalLoss).clamp(0, 1);
  }

  @override
  void initState() {
    super.initState();
    _loadUserWeight();
    _loadGoal(); // ✅ ADD THIS
  }

  Future<void> _loadGoal() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('goals')
          .doc('weight_goal')
          .get();

      if (doc.exists) {
        var data = doc.data()!;

        setState(() {
          targetWeight = (data['targetWeight'] as num?)?.toDouble();
          targetDate = (data['targetDate'] as Timestamp).toDate();

          dateController.text =
              "${targetDate!.day}/${targetDate!.month}/${targetDate!.year}";
        });
      }
    } catch (e) {
      print("Error loading goal: $e");
    }
  }

  Future<void> _loadUserWeight() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        var data = doc.data()!;
        print("Firestore data: $data");

        setState(() {
          currentWeight =
              (data['weight'] as num?)?.toDouble(); // 🔥 safe conversion
        });
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error loading weight: $e");
    }
  }

  Future<void> _saveGoal() async {
    if (weightController.text.isEmpty || targetDate == null) return;

    double weight = double.parse(weightController.text);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('goals')
          .doc('weight_goal')
          .set({
        'targetWeight': weight,
        'targetDate': targetDate,
      });

      setState(() {
        targetWeight = weight;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Goal saved successfully")),
      );
    } catch (e) {
      print("Error saving goal: $e");
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        targetDate = picked;
        dateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      body: SafeArea(
        left: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: currentWeight == null
                  ? const Center(child: CircularProgressIndicator())
                  : hasGoal
                      ? _buildGoalView()
                      : _buildSetGoalForm(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 16, 0), // 👈 MATCH THIS
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Weight Goal",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Track your progress towards your target",
            style: TextStyle(color: Color(0xFF1B5E20)),
          ),
        ],
      ),
    );
  }

  Widget _buildSetGoalForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Set your weight goal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),

          _infoBox(
              "Current Weight", "${currentWeight?.toStringAsFixed(1)} lbs"),

          const SizedBox(height: 16),

          const Text("Desired Weight (lbs)",
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),

          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration("Enter desired weight"),
          ),

          const SizedBox(height: 16),

          const Text("Target Date",
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),

          TextField(
            controller: dateController,
            readOnly: true,
            onTap: _pickDate,
            decoration: _inputDecoration("dd/mm/yyyy"),
          ),

          const Spacer(),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF88B967),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7)
              ),
            ),
            onPressed: _saveGoal,
            child: const Text("Save Goal",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalView() {
    int daysRemaining =
        targetDate!.difference(DateTime.now()).inDays;

    double totalLoss = currentWeight! - targetWeight!;
    double weekly = totalLoss / max(daysRemaining / 7, 1);

    return SingleChildScrollView(
      child: Column(
        children: [
          _goalCard(),
          _timelineCard(daysRemaining),
          _planCard(weekly),
        ],
      ),
    );
  }

  Widget _goalCard() {
    double remaining = currentWeight! - targetWeight!;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Your Goal",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  setState(() {
                    targetWeight = null;
                    targetDate = null;
                  });
                },
                child: const Text("Edit"),
              )
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _miniBox("Current", "${currentWeight!.toStringAsFixed(1)} lbs"),
              _miniBox("Target", "${targetWeight!.toStringAsFixed(1)} lbs"),
            ],
          ),

          const SizedBox(height: 20),

          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 10),

          Text("${remaining.toStringAsFixed(1)} lbs to lose"),
        ],
      ),
    );
  }

  Widget _timelineCard(int days) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Timeline",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Target date: ${dateController.text}"),
          Text("Days remaining: $days"),
        ],
      ),
    );
  }

  Widget _planCard(double weekly) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recommended Plan",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("${weekly.toStringAsFixed(1)} lbs/week",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          const SizedBox(height: 5),
          const Text("This is a healthy and sustainable rate."),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity, // ✅ forces full width
      margin: const EdgeInsets.symmetric(
        horizontal: 16, // same left/right spacing
        vertical: 8,    // smaller gap between cards
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
      ),
      child: child,
    );
  }

  Widget _miniBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade200,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => DashboardPage(userId: widget.userId)),
          );
        } else if (index == 4) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ProfilePage(userId: widget.userId)),
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