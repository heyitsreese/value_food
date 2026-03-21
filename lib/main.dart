import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'signup_page.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

class Food {
  final String name;
  final String budget;

  Food({required this.name, required this.budget});
}

List<Food> foodList = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const ValueFoodApp());
}

class ValueFoodApp extends StatelessWidget {
  const ValueFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ValueFood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ⏳ Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ✅ Logged in
          if (snapshot.hasData) {
            return DashboardPage(userId: snapshot.data!.uid);
          }

          // ❌ Not logged in
          return const LandingPage();
        },
      ),
    );
  }
}

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     // 🔥 CHECK IF LOGGED IN
//     if (user != null) {
//       return DashboardPage(userId: user.uid);
//     } else {
//       return const LoginPage();
//     }
//   }
// }

class LandingPage extends StatelessWidget{
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFA5D6A7),
              Color(0xFFE8F5E9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.03),

                // LOGO

                Image.asset(
                  'assets/logo.png',
                  height: size.height * 0.22,
                ),

                SizedBox(height: 20),

                // TITLE

                Text(
                  "Your Smart Nutrition and\nBudget Companion",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black26,
                        offset: Offset(0,4),
                      )
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // FEATURES

                FeatureCard(
                  icon: Icons.camera_alt,
                  title: "Scan Nutrition Labels",
                  subtitle: "Instantly capture and read nutritional facts",
                ),

                SizedBox(height: 15),

                FeatureCard(
                  icon: Icons.track_changes,
                  title: "AI Diet Recommendations",
                  subtitle: "Get personalized meal plans based on your budget",
                ),

                SizedBox(height: 15),

                FeatureCard(
                  icon: Icons.shield,
                  title: "Allergen Warnings",
                  subtitle: "Stay safe with automatic allergy alerts",
                ),

                SizedBox(height: 30),
                SizedBox(height: 10),

                // 🔘 GET STARTED BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 6,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_)=>SignupPage()),
                      );
                    },
                    child: Text(
                      "Get Started →",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 18),
                    ),
                  ),
                ),
                
                SizedBox(height: 15),

                // 🔁 LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFFA7D489), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_)=>LoginPage()),
                      );
                    },
                    child: Text(
                      "Already have an account? Log In",
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // 🧾 FOOTER TEXT
                Text(
                  "Track. Budget. Eat Healthy.",
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 14,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  "© 2026 ValueFood",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureCard({super.key, 
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(icon, color: Color(0xFF2E7D32)),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}