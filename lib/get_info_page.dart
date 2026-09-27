import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart';
import 'login_page.dart';

class GetInfoPage extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;

  const GetInfoPage({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<GetInfoPage> createState() => _GetInfoPageState();
}

class _GetInfoPageState extends State<GetInfoPage> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final budgetController = TextEditingController();
  final allergyController = TextEditingController();

  List<String> allergies = [];

  Future<void> saveUserData() async {
    try {
      if (allergyController.text.isNotEmpty) {
        allergies.add(allergyController.text.trim());
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({
            'firstName': widget.firstName,
            'lastName': widget.lastName,
            'name': "${widget.firstName} ${widget.lastName}",
            'age': int.tryParse(ageController.text) ?? 0,
            'height': int.tryParse(heightController.text) ?? 0,
            'weight': int.tryParse(weightController.text) ?? 0,
            'budget': double.tryParse(budgetController.text) ?? 0,
            'spent': 0,
            'allergies': allergies,
          });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardPage(userId: widget.userId)),
      );
    } catch (e) {
      print("Error saving user data: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: SingleChildScrollView(
            // padding: const EdgeInsets.all(20),
            // child: Container(
            //   // padding: const EdgeInsets.all(20),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(25),
            //   ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.03),

                // LOGO
                Image.asset(
                  'assets/new_logo.png',
                  height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width / 2,
                  fit: BoxFit.cover,
                ),

                // const Center(
                //   child: Column(
                //     children: [
                //       CircleAvatar(
                //         radius: 40,
                //         backgroundColor: Color(0xFF81C784),
                //         child: Icon(Icons.person, size: 40, color: Colors.white),
                //       ),
                //       SizedBox(height: 10),
                //       Text(
                //         "Create Profile",
                //         style: TextStyle(
                //           fontSize: 22,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       Text("Enter your personal information"),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 20),

                // TITLE
                RichText(
                  text: TextSpan(
                    text: 'Value',
                    style: TextStyle(
                      color: Color.fromRGBO(32, 101, 137, 100),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'Poppins-Bold',
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Food',
                        style: TextStyle(
                          color: Color.fromRGBO(122, 184, 77, 100),
                        ),
                      ),
                    ],
                  ),
                ),

                // under title text
                Text(
                  'Smart Choice. Safe Nutrition. Maximum Value.',
                  style: TextStyle(color: Color.fromRGBO(46, 125, 50, 100)),
                ),

                SizedBox(height: 50),

                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(122, 184, 77, 100),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(40.0),
                      topLeft: Radius.circular(40.0),
                    ),
                  ),
                  height: MediaQuery.of(context).size.height / 1.1,
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      RichText(
                        text: TextSpan(
                          text: 'Create Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          text: 'Start your nutrition tracking journey',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildField("Age", ageController),
                      _buildField("Height (inches)", heightController),
                      _buildField("Weight (lbs)", weightController),
                      _buildField("Available budget (php)", budgetController),
                      const SizedBox(height: 30),
                      // const Text("Food Allergies"),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Allergies',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: TextField(
                                  controller: allergyController,
                                  decoration: InputDecoration(
                                    hintText: "\t e.g. peanuts, dairy",
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white, size: 30),
                            onPressed: addAllergy
                          ),
                        ],
                      ),
                      Wrap(
                        children:
                            allergies.map((item) {
                              return Padding(
                                padding: const EdgeInsets.all(4),
                                child: Chip(
                                  label: Text(item),
                                  deleteIcon: const Icon(Icons.close),
                                  onDeleted: () => removeAllergy(item),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: ElevatedButton(
                          onPressed: saveUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // _buildField("Age", ageController),
                // _buildField("Height (inches)", heightController),
                // _buildField("Weight (lbs)", weightController),
                // _buildField("Available budget (php)", budgetController),

                // const SizedBox(height: 10),

                // const Text("Food Allergies"),
                // Row(
                //   children: [
                //     Expanded(
                //       child: TextField(
                //         controller: allergyController,
                //         decoration: const InputDecoration(
                //           hintText: "e.g. peanuts, dairy",
                //         ),
                //       ),
                //     ),
                //     IconButton(
                //       icon: const Icon(Icons.check, color: Colors.green),
                //       onPressed: addAllergy,
                //     ),
                //   ],
                // ),

                // Wrap(
                //   children:
                //       allergies.map((item) {
                //         return Padding(
                //           padding: const EdgeInsets.all(4),
                //           child: Chip(
                //             label: Text(item),
                //             deleteIcon: const Icon(Icons.close),
                //             onDeleted: () => removeAllergy(item),
                //           ),
                //         );
                //       }).toList(),
                // ),

                // const SizedBox(height: 20),

                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: saveUserData,
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: const Color(0xFF81C784),
                //       padding: const EdgeInsets.all(15),
                //     ),
                //     child: const Text(
                //       "Create Account",
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ),
                // ),
              ],
            ),
            // ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: label,
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
