import 'package:ai_fitmate/Pages/Login.dart';
import 'package:ai_fitmate/Pages/SignUp.dart';
import 'package:flutter/material.dart';

class GettingStarted2 extends StatelessWidget {
  const GettingStarted2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo (flex: 1)
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFCDFF00),
                      size: screenWidth * 0.07,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "AI FitMate",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.055,
                      ),
                    ),
                  ],
                ),
              ),

              // Title & Subtitle (flex: 2)
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Getting Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.055,
                      ),
                    ),
                    SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        "Your AI-powered fitness companion for smarter workouts, real-time posture correction, and adaptive plans.",
                        style: TextStyle(
                          fontSize: screenWidth * 0.037,
                          color: Colors.grey[400],
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Image Container (flex: 3)
              Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1a2332),
                        Color(0xFF0f1419),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'lib/images/GettingStarted1.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.fitness_center, size: 48, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Feature Cards (flex: 4)



              Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: _buildFeatureCard(
                        context,
                        icon: Icons.person_add_outlined,
                        title: "Create your account",
                        subtitle: "Sign up to personalize your program.",
                      ),
                    ),
                    SizedBox(height: 8,),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: _buildFeatureCard(
                        context,
                        icon: Icons.crop_free,
                        title: "Enable posture coach",
                        subtitle: "Get real-time form feedback using  camera.",
                      ),
                    ),
                    SizedBox(height: 8),


                  ],
                ),
              ),

              // Bottom Section: Button + Link + Indicators (flex: 2)
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () { Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                              (route) => false,
                        );},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFCDFF00),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2),

                    // Already have account
                    TextButton(
                      onPressed: () { Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                            (route) => false,
                      );},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        minimumSize: Size(0, 36),
                      ),
                      child: Text(
                        "I already have an account",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: screenWidth * 0.038,
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
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.035,
        vertical: screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF1a1d24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Color(0xFF2a2d34),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: screenWidth * 0.065),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.041,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: screenWidth * 0.033,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


