import 'package:ai_fitmate/Pages/Login.dart';
import 'package:ai_fitmate/components/topSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';


class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUp> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthdateController = TextEditingController();

  String? _selectedGoal;
  final List<Map<String, dynamic>> _goals = [
    {'name': 'Lose Weight', 'icon': Icons.trending_down, 'color': Color(0xFFFF6B6B)},
    {'name': 'Build Muscle', 'icon': Icons.fitness_center, 'color': Color(0xFF4ECDC4)},
    {'name': 'Stay Fit', 'icon': Icons.favorite, 'color': Color(0xFFFF6B9D)},
    {'name': 'Improve Flexibility', 'icon': Icons.self_improvement, 'color': Color(0xFF95E1D3)},
    {'name': 'Increase Endurance', 'icon': Icons.directions_run, 'color': Color(0xFFFFA07A)},
    {'name': 'General Health', 'icon': Icons.health_and_safety, 'color': Color(0xFF9B59B6)},
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthdateController.dispose();

    super.dispose();
  }

  bool _validateFields() {
    if (_firstNameController.text.trim().isEmpty) {
      _showError("First name is required");
      return false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      _showError("Last name is required");
      return false;
    }

    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains("@")) {
      _showError("Enter a valid email");
      return false;
    }

    if (_passwordController.text.length < 8) {
      _showError("Password must be at least 8 characters");
      return false;
    }

    if (_confirmPasswordController.text != _passwordController.text) {
      _showError("Passwords do not match");
      return false;
    }

    if (_selectedGoal == null) {
      _showError("Please select your primary goal");
      return false;
    }

    if (_birthdateController.text.trim().isEmpty) {
      _showError("Please select your birthdate");
      return false;
    }

    return true;
  }

  void _showError(String message) {
    showAwesomeSnackBar(context, message, ContentType.failure);
  }

  void _showGoalPicker(BuildContext context, bool isSmallScreen) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF48484A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Select Your Primary Goal',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22 : 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose what you want to achieve',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 15,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      ...List.generate(_goals.length, (index) {
                        final goal = _goals[index];
                        final isSelected = _selectedGoal == goal['name'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedGoal = goal['name'];
                              });
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2C2C2E)
                                    : const Color(0xFF2C2C2E).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFCDFF00)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (goal['color'] as Color).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      goal['icon'] as IconData,
                                      color: goal['color'] as Color,
                                      size: isSmallScreen ? 24 : 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      goal['name'] as String,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 15 : 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFCDFF00),
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFCDFF00),
              onPrimary: Colors.black,
              surface: Color(0xFF1C1C1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1C1C1E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final padding = size.width * 0.05;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                _buildHeader(context, isSmallScreen),
                SizedBox(height: size.height * 0.03),
                _buildSignUpCard(context, size, isSmallScreen),
                SizedBox(height: size.height * 0.02),
                _buildLoginLink(context, isSmallScreen),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Sign Up',
          style: TextStyle(
            fontSize: isSmallScreen ? 32 : 38,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF2C2C2E)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 28,
              vertical: isSmallScreen ? 10 : 12,
            ),
          ),
          child: Text(
            'Help',
            style: TextStyle(
              fontSize: isSmallScreen ? 15 : 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpCard(BuildContext context, Size size, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
      color: const Color(0xFF12131A),
      borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Color(0xFF212229), // your border color
            width: 1.5,               // thickness of border
          )
      ),
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF101118),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF212229), // your border color
                    width: 1.5,               // thickness of border
                  ),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your FitMate\naccount',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Personalized plans, real-time posture\ncoaching, and more',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 15,
                        color: const Color(0xFF8E8E93),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  hint: 'First name',
                  icon: Icons.person_outline,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
                  hint: 'Last name',
                  icon: Icons.person_outline,
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            hint: 'Email address',
            icon: Icons.email_outlined,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _passwordController,
            hint: 'Password • 8+ characters',
            icon: Icons.lock_outline,
            isPassword: true,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _confirmPasswordController,
            hint: 'Confirm password',
            icon: Icons.lock_outline,
            isPassword: true,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGoalField(
                  value: _selectedGoal,
                  hint: 'Primary goal',
                  icon: Icons.track_changes_outlined,
                  onTap: () => _showGoalPicker(context, isSmallScreen),
                  isSmallScreen: isSmallScreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  controller: _birthdateController,
                  hint: 'Birthdate',
                  icon: Icons.calendar_today_outlined,
                  onTap: () => _selectDate(context),
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'By continuing, you agree to our Terms and Privacy\nPolicy.',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              color: const Color(0xFF8E8E93),
              height: 1.4,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 52 : 58,
            child: ElevatedButton(
              onPressed: ()
              {
                if (_validateFields()) {
                  showAwesomeSnackBar(context, "Account Created Successfully", ContentType.success);

                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                );
              }},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCDFF00),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                'Create account',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Center(
            child: Text(
              'or continue with',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 15,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.apple,
                  label: 'Apple',
                  isSmallScreen: isSmallScreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.email_outlined,
                  label: 'Google',
                  isSmallScreen: isSmallScreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16171D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF212229), // your border color
          width: 1.5,               // thickness of border
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF8E8E93),
            fontSize: isSmallScreen ? 14 : 16,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF8E8E93),
            size: isSmallScreen ? 20 : 22,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isSmallScreen ? 14 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required bool isSmallScreen,
  }) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF2C2C2E)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallScreen ? 24 : 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalField({
    required String? value,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16171D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF212229), // your border color
          width: 1.5,               // thickness of border
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isSmallScreen ? 14 : 16,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF8E8E93),
                size: isSmallScreen ? 20 : 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value ?? hint,
                  style: TextStyle(
                    color: value != null ? Colors.white : const Color(0xFF8E8E93),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF8E8E93),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }




  Widget _buildDateField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16171D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF212229),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF8E8E93),
            fontSize: isSmallScreen ? 14 : 16,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF8E8E93),
            size: isSmallScreen ? 20 : 22,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isSmallScreen ? 14 : 16,
          ),
        ),
      ),
    );
  }


  Widget _buildLoginLink(BuildContext context, bool isSmallScreen) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        },
        child: RichText(
          text: TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(
              color: const Color(0xFF8E8E93),
              fontSize: isSmallScreen ? 14 : 16,
            ),
            children: const [
              TextSpan(
                text: 'Log in',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}