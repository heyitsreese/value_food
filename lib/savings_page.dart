import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_page.dart';
import 'label_page.dart';
import 'goals_info_page.dart';
import 'dashboard_page.dart';
import 'budget_page.dart';

class SavingsPage extends StatefulWidget {
  final String userId;

  const SavingsPage({super.key, required this.userId});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  String selectedType = "Monthly";

  final TextEditingController monthlyController = TextEditingController();
  final TextEditingController weeklyController = TextEditingController();

  // Budget overview data
  double monthlyLimit = 0;
  double spent = 0;
  DateTime calendarMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadOverviewData();
  }

  Future<void> _loadOverviewData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        monthlyLimit = (data['budget'] ?? data['monthlyLimit'] ?? 0).toDouble();
        spent = (data['spent'] ?? 0).toDouble();
        monthlyController.text =
            monthlyLimit > 0 ? monthlyLimit.toStringAsFixed(0) : '';
      });
    }
  }

  double get remaining => (monthlyLimit - spent).clamp(0, double.infinity);
  double get spentProgress =>
      monthlyLimit == 0 ? 0 : (spent / monthlyLimit).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(side: BorderSide(width: 3,color: const Color(0xFF2E7D32))),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LabelPage(userId: widget.userId),
              ),
            );
          },
          child: Image.asset('assets/icons/scan_icon.png', color:const Color(0xFF2E7D32), height: 32)
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
      body: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(122, 184, 77, 100)),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Padding(
                  // padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 1),
                      _buildButtons(),
                    ],
                  ),
                ),

                const SizedBox(height: 1),

                // ── Budget Settings Card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: _buildBudgetCard(),
                ),

                const SizedBox(height: 20),

                // ── Budget Overview Card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: _buildBudgetOverview(),
                ),

                const SizedBox(height: 20),

                // ── Spending Calendar Card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: _buildSpendingCalendar(),
                ),

                const SizedBox(height: 20),

                // ── Add Expense Card ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                  child: _buildAddExpense(),
                ),
              ],
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

  // build buttons at the top
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
                style: TextStyle(color: Colors.white,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
                 
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Budget Settings",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B1B1B),
            ),
          ),

          const SizedBox(height: 20),

          // Budget Type label
          const Text(
            "Budget Type",
            style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 10),

          // Toggle buttons
          Row(
            children: [
              _typeButton("Monthly"),
              const SizedBox(width: 10),
              _typeButton("Weekly"),
            ],
          ),

          const SizedBox(height: 20),

          // Monthly limit
          const Text(
            "Monthly limit",
            style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 8),
          _inputField(monthlyController, "e.g. 4000"),

          const SizedBox(height: 14),

          // Weekly limit
          const Text(
            "Weekly limit",
            style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 8),
          _inputField(weeklyController, "e.g. 1000"),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: const Color(0xFF8BC34A),
                    backgroundColor:  Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save budget",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF444444),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFCCCCCC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeButton(String type) {
    final isSelected = selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFCCCCCC),
            ),
          ),
          child: Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF444444),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1B1B1B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
          ),
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    final monthly = double.tryParse(monthlyController.text) ?? 0;
    final weekly = double.tryParse(weeklyController.text) ?? 0;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
          'budget': monthly, // also update main budget field
          'monthlyLimit': monthly,
          'weeklyLimit': weekly,
        });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Budget saved successfully"),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildBudgetOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Budget Overview",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Scroll up to edit — or you can open a dialog
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: Color(0xFF444444),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stat boxes
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7EE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "₱",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromRGBO(103, 129, 185, 100),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 6),
                     const Text(
                        "Monthly Limit",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₱${monthlyLimit.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(103, 129, 185, 100),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7EE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.trending_down_rounded,
                        size: 24,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Remaining",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₱${remaining.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E7D32),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Spent label + progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Spent",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              Text(
                spent.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: spentProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFFD9EDD6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingCalendar() {
    final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final firstDay = DateTime(calendarMonth.year, calendarMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      calendarMonth.year,
      calendarMonth.month,
    );
    final startWeekday = firstDay.weekday % 7; // 0 = Sunday

    final monthName =
        [
          '',
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ][calendarMonth.month];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + month navigator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Spending \nCalendar",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        calendarMonth = DateTime(
                          calendarMonth.year,
                          calendarMonth.month - 1,
                        );
                      });
                    },
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF2E7D32),
                      size: 22,
                    ),
                  ),
                  Text(
                    "$monthName ${calendarMonth.year}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        calendarMonth = DateTime(
                          calendarMonth.year,
                          calendarMonth.month + 1,
                        );
                      });
                    },
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF2E7D32),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                daysOfWeek
                    .map(
                      (d) => SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox();

              final day = index - startWeekday + 1;
              final isToday =
                  day == DateTime.now().day &&
                  calendarMonth.month == DateTime.now().month &&
                  calendarMonth.year == DateTime.now().year;

              return Container(
                decoration: BoxDecoration(
                  color:
                      isToday
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$day",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isToday ? Colors.white : const Color(0xFF333333),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _legendItem(const Color(0xFFF2F2F2), "No spend"),
              const SizedBox(width: 12),
              _legendItem(const Color(0xFFA8D5A2), "Low"),
              const SizedBox(width: 12),
              _legendItem(const Color(0xFFFFE082), "Medium"),
              const SizedBox(width: 12),
              _legendItem(const Color(0xFFFFCDD2), "High"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddExpense() {
    return GestureDetector(
      onTap: () {
        // TODO: open add expense dialog/sheet
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Add Expense",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B1B1B),
              ),
            ),
            // + BUTTON
               GestureDetector(
                onTap: () async {
                  //  Add Expense options 
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 10,
      child: SizedBox(
        height: 62,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, "home", false, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DashboardPage(userId: widget.userId),
                ),
              );
            }),
            _navItem(Icons.savings_rounded, "budget", true, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BudgetPage(userId: widget.userId),
                ),
              );
            }),
            const SizedBox(width: 48),
            _navItem(Icons.flag_rounded, "goals", false, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GoalsInfoPage(userId: widget.userId),
                ),
              );
            }),
            _navItem(Icons.person_rounded, "profile", false, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(userId: widget.userId),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isActive ? const Color(0xFF2E7D32) : const Color(0xFFB0BEC5),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color:
                  isActive ? const Color(0xFF2E7D32) : const Color(0xFFB0BEC5),
            ),
          ),
        ],
      ),
    );
  }
}
