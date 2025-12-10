import 'package:ai_fitmate/Pages/HomeScreen.dart';
import 'package:ai_fitmate/Pages/SignUp.dart';
import 'package:ai_fitmate/components/topSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:ai_fitmate/utils/prefs.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  final List<Map<String, String>> mockUsers = [
    {'email': 'user1@example.com', 'password': 'password123'},
    {'email': 'user2@example.com', 'password': 'pass456'},
  ];

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter both email and password');
      return;
    }

    final user = mockUsers.firstWhere(
          (user) => user['email'] == email && user['password'] == password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      await saveEmail(email);
      showAwesomeSnackBar(context, "Login Successfull", ContentType.success);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      _showSnackBar('Invalid email or password');
    }
  }

  void _showSnackBar(String message) {
    showAwesomeSnackBar(context, message, ContentType.failure);
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      // Logo and App Name
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: const Color(0xFFCDFF00),
                            size: size.width * 0.1,
                          ),
                          SizedBox(width: size.width * 0.03),
                          Text(
                            'AI FitMate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.07,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.04),
                      // Welcome back text
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      // Subtitle
                      Text(
                        'Log in to continue your adaptive workouts and progress.',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: size.width * 0.04,
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                      // Main form container with grey background
                      Container(
                        padding: EdgeInsets.all(size.width * 0.05),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12131A),
                          borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Color(0xFF212229), // your border color
                              width: 1.5,               // thickness of border
                            )
                        ),
                        child: Column(
                          children: [
                            // Email TextField
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF16171D),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFF212229), // your border color
                                  width: 1.5,               // thickness of border
                                ),
                              ),
                              child: TextField(
                                controller: _emailController,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.04,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Email address',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: size.width * 0.04,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.grey[600],
                                    size: size.width * 0.06,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.04,
                                    vertical: size.height * 0.02,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            // Password TextField
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF16171D),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFF212229),
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.04,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: size.width * 0.04,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[600],
                                    size: size.width * 0.06,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey[600],
                                      size: size.width * 0.06,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.04,
                                    vertical: size.height * 0.02,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            // Remember me and Forgot password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.06,
                                      height: size.width * 0.06,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                        fillColor: MaterialStateProperty.all(
                                          const Color(0xFF2C2C2E),
                                        ),
                                        checkColor: const Color(0xFFCDFF00),
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: size.width * 0.037,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: const Color(0xFFCDFF00),
                                      fontSize: size.width * 0.037,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.025),
                            // Log In Button
                            SizedBox(
                              width: double.infinity,
                              height: size.height * 0.065,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCDFF00),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            // Use passkey Button
                            SizedBox(
                              width: double.infinity,
                              height: size.height * 0.065,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF2C2C2E),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Use passkey',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.045,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      // Or continue with
                      Center(
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(Icons.apple, size),
                          SizedBox(width: size.width * 0.04),
                          _socialButton(Icons.email_outlined, size),
                          SizedBox(width: size.width * 0.04),
                          _socialButton(Icons.public, size),
                        ],
                      ),
                      SizedBox(height: size.height * 0.03),
                      // Create account section with border
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.02,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF2C2C2E),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New to AI FitMate?',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: size.width * 0.04,
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUp()),
                                );
                              },
                              child: Text(
                                'Create account',
                                style: TextStyle(
                                  color: const Color(0xFFCDFF00),
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Size size) {
    return Container(
      width: size.width * 0.15,
      height: size.width * 0.15,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size.width * 0.065,
      ),
    );
  }
}