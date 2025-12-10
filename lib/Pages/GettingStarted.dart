import 'package:flutter/material.dart';

class GettingStarted extends StatelessWidget {
  const GettingStarted({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFCDFF00),
                      size: screenWidth * 0.08,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "AI FitMate",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.06,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                // Title
                Text(
                  "Getting Started",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.09,
                  ),
                ),
                SizedBox(height: 12),

                // Subtitle
                Text(
                  "Your AI-powered fitness companion for smarter workouts, real-time posture correction, and adaptive plans.",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24),

                // Image Container
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.25,
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
                          child: Icon(Icons.fitness_center, size: 64, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Feature Cards
                _buildFeatureCard(
                  context,
                  icon: Icons.person_add_outlined,
                  title: "Create your account",
                  subtitle: "Sign up to personalize your program and sync your data.",
                ),
                SizedBox(height: 12),

                _buildFeatureCard(
                  context,
                  icon: Icons.crop_free,
                  title: "Enable posture coach",
                  subtitle: "Get real-time form feedback using your camera.",
                ),
                SizedBox(height: 12),

                _buildFeatureCard(
                  context,
                  icon: Icons.crop_free,
                  title: "Enable posture coach",
                  subtitle: "Get real-time form feedback using your camera.",
                ),

                SizedBox(height: screenHeight * 0.04),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {},
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
                SizedBox(height: 16),

                // Already have account
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "I already have an account",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPageIndicator(true),
                    SizedBox(width: 8),
                    _buildPageIndicator(false),
                    SizedBox(width: 8),
                    _buildPageIndicator(false),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
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
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Color(0xFF1a1d24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF2a2d34),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: screenWidth * 0.07),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.043,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: screenWidth * 0.035,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[700],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

