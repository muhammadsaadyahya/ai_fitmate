import 'package:flutter/material.dart';
import 'CameraScreen.dart';
import 'LateralRaiseScreen.dart';
import 'ShoulderPressScreen.dart';
import 'PlankPoseCorrectorScreen.dart';
import 'PushupScreen.dart';
import 'SquatsScreen.dart';
import 'HighKneesScreen.dart';
import 'BicepCurlsScreen.dart';
import 'PullUpScreen.dart';
import 'CrunchesScreen.dart';
import 'TricepsDipsScreen.dart';
import 'GluteBridgesScreen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mock workout data
  final List<Map<String, dynamic>> workouts = [
    {
      'title': 'Plank Pose Corrector',
      'subtitle': 'Core - Form Check',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/MobilityFlow.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'Plank', 'details': '3 sets × 45 seconds'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
    {
      'title': 'Pushup Counter',
      'subtitle': 'Upper Body - Reps + Form',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/Muscular Workout.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'Push-ups', 'details': '3 sets × 12 reps'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
    {
      'title': 'Lateral Raise Counter',
      'subtitle': 'Shoulders - Reps + Form',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/Power Yoga Workout.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'Lateral Raises', 'details': '3 sets × 12 reps'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
    {
      'title': 'Shoulder Press Counter',
      'subtitle': 'Shoulders - Reps + Form',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/Muscular Workout.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'Shoulder Press', 'details': '3 sets × 10 reps'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
    {
      'title': 'Squats Counter',
      'subtitle': 'Lower Body - Reps + Form',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/Power Yoga Workout.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'Squats', 'details': '3 sets × 15 reps'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
    {
      'title': 'High Knees Counter',
      'subtitle': 'Cardio - Reps + Form',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/HIIT Adaptive Training.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'High Knees', 'details': '3 sets × 30 seconds'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
    {
      'title': 'Bicep Curls Counter',
      'subtitle': 'Arms - Reps + Form',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/Muscular Workout.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'Bicep Curls', 'details': '3 sets × 12 reps'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
    {
      'title': 'Pull Up Counter',
      'subtitle': 'Back - Reps + Form',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/Muscular Workout.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'Pull-ups', 'details': '3 sets × 8 reps'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
    {
      'title': 'Crunches Counter',
      'subtitle': 'Core - Reps + Form',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/Power Yoga Workout.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'Crunches', 'details': '3 sets × 15 reps'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
    {
      'title': 'Triceps Dips Counter',
      'subtitle': 'Arms - Reps + Form',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/Muscular Workout.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'Triceps Dips', 'details': '3 sets × 10 reps'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
    {
      'title': 'Glute Bridges Counter',
      'subtitle': 'Glutes - Reps + Form',
      'progress': 0.00,
      'schedule': [false, false, false, false, false, false, false],
      'image': 'lib/images/Power Yoga Workout.jpeg',
      'exercises': [
        {'name': 'Warm-up', 'details': '5 minutes'},
        {'name': 'Glute Bridges', 'details': '3 sets × 15 reps'},
        {'name': 'Cool-down', 'details': '5 minutes'},
      ],
    },
  ];

  final List<String> weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final filteredWorkouts = workouts.where((workout) {
      return workout['title'].toString().toLowerCase().contains(_searchQuery) ||
          workout['subtitle'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(width, height),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.01,
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFCDFF00),
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.02,
                ),
                itemCount: filteredWorkouts.length,
                itemBuilder: (context, index) {
                  return _buildWorkoutCard(
                    filteredWorkouts[index],
                    width,
                    height,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.02,
      ),
      child: Text(
        'SELECT TRAINING MODE',
        style: TextStyle(
          fontSize: width * 0.065,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(
    Map<String, dynamic> workout,
    double width,
    double height,
  ) {
    return GestureDetector(
      onTap: () {
        _showWorkoutDetails(workout, width, height);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: height * 0.02),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              SizedBox(
                height: height * 0.28,
                width: double.infinity,
                child: Image.asset(
                  workout['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF1B1D26),
                      child: Icon(
                        Icons.fitness_center,
                        color: const Color(0xFFCDFF00),
                        size: width * 0.15,
                      ),
                    );
                  },
                ),
              ),
              // Gradient Overlay
              Container(
                height: height * 0.28,
                color: Colors.transparent,
              ),
              // Content
              Positioned(
                left: width * 0.05,
                right: width * 0.05,
                bottom: height * 0.02,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout['title'],
                                style: TextStyle(
                                  fontSize: width * 0.055,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: height * 0.005),
                              Text(
                                workout['subtitle'],
                                style: TextStyle(
                                  fontSize: width * 0.038,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFAAAAAA),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Progress Circle
                        SizedBox(
                          width: width * 0.15,
                          height: width * 0.15,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: workout['progress'],
                                strokeWidth: width * 0.01,
                                backgroundColor: const Color(0xFF2C2C2E),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFCDFF00),
                                ),
                              ),
                              Text(
                                '${(workout['progress'] * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFCDFF00),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.015),
                    // Workout Schedule
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workout Schedule',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Row(
                          children: List.generate(
                            7,
                            (index) => Padding(
                              padding: EdgeInsets.only(
                                right: index < 6 ? width * 0.015 : 0,
                              ),
                              child: _buildDayIndicator(
                                weekDays[index],
                                workout['schedule'][index],
                                width,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDayIndicator(String day, bool isActive, double width) {
    return Container(
      width: width * 0.065,
      height: width * 0.065,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFFCDFF00) : const Color(0xFF2C2C2E),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: width * 0.025,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF000000) : const Color(0xFF8E8E93),
          ),
        ),
      ),
    );
  }

  void _showWorkoutDetails(
    Map<String, dynamic> workout,
    double width,
    double height,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12131A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Container(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: width * 0.12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8E8E93),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                // Workout Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    workout['image'],
                    width: double.infinity,
                    height: height * 0.25,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: height * 0.02),
                Text(
                  workout['title'],
                  style: TextStyle(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  workout['subtitle'],
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                SizedBox(height: height * 0.02),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Duration', '45 min', width),
                    _buildStatItem('Calories', '320 kcal', width),
                    _buildStatItem('Level', 'Medium', width),
                  ],
                ),
                SizedBox(height: height * 0.02),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  'This workout focuses on building strength and endurance. Perfect for those looking to improve their fitness level with a balanced routine targeting major muscle groups.',
                  style: TextStyle(
                    fontSize: width * 0.038,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: height * 0.02),
                Text(
                  'Exercises Included',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.01),
                ...?((workout['exercises'] as List<dynamic>?)?.map((exercise) {
                  return _buildExerciseItem(
                    exercise['name'] as String,
                    exercise['details'] as String,
                    width,
                  );
                }).toList()),
                SizedBox(height: height * 0.02),
                // Start Workout Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _startWorkout(workout);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: height * 0.02),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDFF00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Start Workout',
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, double width) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFCDFF00),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.032,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseItem(String name, String details, double width) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: width * 0.08,
                height: width * 0.08,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: const Color(0xFFCDFF00),
                  size: width * 0.04,
                ),
              ),
              SizedBox(width: width * 0.03),
              Text(
                name,
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            details,
            style: TextStyle(
              fontSize: width * 0.032,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  void _startWorkout(Map<String, dynamic> workout) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12131A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: width * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E8E93),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'Start ${workout['title']}',
              style: TextStyle(
                fontSize: width * 0.06,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.01),
            Text(
              'Enable camera for form tracking and posture analysis during your workout',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.038,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8E8E93),
              ),
            ),
            SizedBox(height: height * 0.03),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: height * 0.018),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1D26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2C2C2E),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            if (workout['title'] == 'Plank Pose Corrector') {
                              return const PlankPoseCorrectorScreen();
                            }
                            if (workout['title'] == 'Pushup Counter') {
                              return const PushupScreen();
                            }
                            if (workout['title'] == 'Lateral Raise Counter') {
                              return const LateralRaiseScreen();
                            }
                            if (workout['title'] == 'Shoulder Press Counter') {
                              return const ShoulderPressScreen();
                            }
                            if (workout['title'] == 'Squats Counter') {
                              return const SquatsScreen();
                            }
                            if (workout['title'] == 'High Knees Counter') {
                              return const HighKneesScreen();
                            }
                            if (workout['title'] == 'Bicep Curls Counter') {
                              return const BicepCurlsScreen();
                            }
                            if (workout['title'] == 'Pull Up Counter') {
                              return const PullUpScreen();
                            }
                            if (workout['title'] == 'Crunches Counter') {
                              return const CrunchesScreen();
                            }
                            if (workout['title'] == 'Triceps Dips Counter') {
                              return const TricepsDipsScreen();
                            }
                            if (workout['title'] == 'Glute Bridges Counter') {
                              return const GluteBridgesScreen();
                            }
                            return CameraScreen(workoutName: workout['title']);
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: height * 0.018),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCDFF00),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: const Color(0xFF000000),
                              size: width * 0.05,
                            ),
                            SizedBox(width: width * 0.02),
                            Text(
                              'Open Camera',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF000000),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }
}
