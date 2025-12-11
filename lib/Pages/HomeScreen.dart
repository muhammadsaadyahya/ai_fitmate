import "package:flutter/material.dart";
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../components/topSnackBar.dart';
import 'CameraScreen.dart';



class HomeScreen extends StatefulWidget {
  final TabController tabController;

  const HomeScreen({Key? key, required this.tabController}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {

  // Dummy data from backend
  final Map<String, dynamic> userData = {
    'name': 'Alex',
    'greeting': 'Good Morning',
    'message': 'Your adaptive plan is ready. Let\'s crush it!',
    'profileImage':
    'lib/images/profilepic.jpeg',
    'activeStreak': 7,
    'todayCalories': 1250,
    'caloriesGoal': 2100,
    'weeklyMinutes': 142,
    'minutesTarget': 180,
    'overallProgress': 55,
  };

  final List<Map<String, dynamic>> recommendedWorkouts = [
    {
      'title': 'Endurance Run',
      'subtitle': '30 min • Low Impact',
      'image':
      'lib/images/EnduranceRun.jpeg',
      'progress': 20,
      'type': 'workout',
    },
    {
      'title': 'Protein Boost Lunch',
      'subtitle': 'Meal Plan • 550 kcal',
      'image':
      'lib/images/ProtienBoost.jpeg',
      'progress': null,
      'type': 'meal',
    },
    {
      'title': 'Mobility Flow',
      'subtitle': '15 min • Recovery',
      'image':
      'lib/images/MobilityFlow.jpeg',
      'progress': 0,
      'type': 'workout',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.02),
                _buildHeader(context, width, height),
                SizedBox(height: height * 0.025),
                _buildGreetingCard(context, width, height),
                SizedBox(height: height * 0.025),
                _buildStatsCards(context, width, height),
                SizedBox(height: height * 0.025),
                _buildProgressCard(context, width, height),
                SizedBox(height: height * 0.03),
                _buildQuickActions(context, width, height),
                SizedBox(height: height * 0.03),
                _buildRecommendedSection(context, width, height),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'DASHBOARD',
          style: TextStyle(
            fontSize: width * 0.08,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                widget.tabController.animateTo(1);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.012,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFCDFF00),
                  borderRadius: BorderRadius.circular(width * 0.06),
                ),
                child: Text(
                  'Start',
                  style: TextStyle(
                    fontSize: width * 0.042,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.03),
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: width * 0.065,
                  ),
                  onPressed: () {
                    _showNotifications(width, height);
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: width * 0.025,
                    height: width * 0.025,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDFF00),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreetingCard(BuildContext context, double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(width * 0.12),
        border: Border.all(
          color: const Color(0xFF212229),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: width * 0.08,
            backgroundColor: Colors.grey[900],
            child: ClipOval(
              child: Image.asset(
               userData["profileImage"],
                fit: BoxFit.cover,
                width: width * 0.16,
                height: width * 0.16,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.fitness_center,
                    size: width * 0.10,
                    color: Colors.grey[600],
                  );
                },
              ),
            ),
          ),

          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${userData['greeting']}, ${userData['name']}',
                  style: TextStyle(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  userData['message'],
                  style: TextStyle(
                    fontSize: width * 0.037,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, double width, double height) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // --- Card 1 ---
          Expanded(
            child: Container(
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFF12131A),
                borderRadius: BorderRadius.circular(width * 0.04),
                border: Border.all(
                  color: const Color(0xFF212229),
                  width: 1.5,
                ),
              ),
              child: _buildStatCard(
                title: 'Active Streak',
                value: '${userData['activeStreak']} days',
                subtitle: 'Keep it up!',
                width: width,
                height: height,
              ),
            ),
          ),

          SizedBox(width: width * 0.03),

          // --- Card 2 ---
          Expanded(
            child: Container(
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFF12131A),
                borderRadius: BorderRadius.circular(width * 0.04),
                border: Border.all(
                  color: const Color(0xFF212229),
                  width: 1.5,
                ),
              ),
              child: _buildStatCard(
                title: 'Today\nCalories',
                value: '${userData['todayCalories']}',
                subtitle: 'of ${userData['caloriesGoal']} goal',
                width: width,
                height: height,
              ),
            ),
          ),

          SizedBox(width: width * 0.03),

          // --- Card 3 ---
          Expanded(
            child: Container(
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFF12131A),
                borderRadius: BorderRadius.circular(width * 0.04),
                border: Border.all(
                  color: const Color(0xFF212229),
                  width: 1.5,
                ),
              ),
              child: _buildStatCard(
                title: 'Weekly\nMinutes',
                value: '${userData['weeklyMinutes']}',
                subtitle: 'of ${userData['minutesTarget']} target',
                width: width,
                height: height,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required double width,
    required double height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: width * 0.035,
            color: const Color(0xFF8E8E93),
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: height * 0.008),
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.065,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        SizedBox(height: height * 0.003),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: width * 0.03,
            color: const Color(0xFF8E8E93),
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }


  Widget _buildProgressCard(BuildContext context, double width, double height) {
    final progress = userData['overallProgress'] / 100;
    return Container(
      padding: EdgeInsets.all(width * 0.055),
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(width * 0.05),
        border: Border.all(
          color: const Color(0xFF212229),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Progress',
                  style: TextStyle(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  'Your plan completion',
                  style: TextStyle(
                    fontSize: width * 0.037,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: width * 0.24,
            height: width * 0.24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: width * 0.24,
                  height: width * 0.24,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: width * 0.025,
                    backgroundColor: const Color(0xFF2C2C2E),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFCDFF00),
                    ),
                  ),
                ),
                Text(
                  '${userData['overallProgress']}%',
                  style: TextStyle(
                    fontSize: width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFCDFF00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8E8E93),
          ),
        ),
        SizedBox(height: height * 0.02),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.fitness_center,
                label: 'Start Workout',
                width: width,
                height: height,
                onTap: () {
                  _openCamera();
                },
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: _buildActionButton(
                icon: Icons.center_focus_strong,
                label: 'Posture Coach',
                width: width,
                height: height,
                onTap: () {
                  widget.tabController.animateTo(1);
                },
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Ask AI',
                width: width,
                height: height,
                onTap: () {
                  // Navigate to AI chatbot tab
                  widget.tabController.animateTo(3);

                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required double width,
    required double height,
    VoidCallback? onTap,  // add callback
  }) {
    return GestureDetector(
      onTap: onTap, // pass the callback
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: height * 0.025,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF12131A),
          borderRadius: BorderRadius.circular(width * 0.04),
          border: Border.all(
            color: const Color(0xFF212229),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: width * 0.08,
            ),
            SizedBox(height: height * 0.012),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedSection(
      BuildContext context, double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended For You',
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8E8E93),
          ),
        ),
        SizedBox(height: height * 0.02),
        ...recommendedWorkouts.map((workout) {
          return Padding(
            padding: EdgeInsets.only(bottom: height * 0.02),
            child: _buildRecommendedCard(
              image: workout['image'],
              title: workout['title'],
              subtitle: workout['subtitle'],
              progress: workout['progress'] != null
                  ? workout['progress'] / 100.0
                  : null,
              hasCheckIcon: workout['type'] == 'meal',
              width: width,
              height: height,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecommendedCard({
    required String image,
    required String title,
    required String subtitle,
    double? progress,
    bool hasCheckIcon = false,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: () {
        _showRecommendedDetails(
          image: image,
          title: title,
          subtitle: subtitle,
          isMeal: hasCheckIcon,
          width: width,
          height: height,
        );
      },
      child: Container(
        height: height * 0.25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.05),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(width * 0.055),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width * 0.05),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0xB3000000),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: width * 0.065,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: height * 0.005),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: width * 0.037,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (progress != null)
                    SizedBox(
                      width: width * 0.15,
                      height: width * 0.15,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: width * 0.15,
                            height: width * 0.15,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: width * 0.012,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFCDFF00),
                              ),
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: width * 0.037,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFCDFF00),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (hasCheckIcon)
                    Container(
                      width: width * 0.15,
                      height: width * 0.15,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCDFF00).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: const Color(0xFFCDFF00),
                        size: width * 0.07,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecommendedDetails({
    required String image,
    required String title,
    required String subtitle,
    required bool isMeal,
    required double width,
    required double height,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12131A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
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
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    image,
                    width: double.infinity,
                    height: height * 0.25,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: height * 0.25,
                        color: const Color(0xFF1B1D26),
                        child: Icon(
                          isMeal ? Icons.restaurant : Icons.fitness_center,
                          color: const Color(0xFFCDFF00),
                          size: width * 0.15,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: height * 0.02),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                SizedBox(height: height * 0.02),
                // Stats Row
                if (!isMeal)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailStatItem('Duration', '30 min', width),
                      _buildDetailStatItem('Calories', '280 kcal', width),
                      _buildDetailStatItem('Level', 'Low', width),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailStatItem('Calories', '550 kcal', width),
                      _buildDetailStatItem('Protein', '45g', width),
                      _buildDetailStatItem('Carbs', '52g', width),
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
                  isMeal
                      ? 'A balanced high-protein meal perfect for post-workout recovery. Packed with lean protein, healthy fats, and complex carbohydrates to fuel your fitness goals.'
                      : 'A carefully designed workout routine that builds endurance and strength. Perfect for improving cardiovascular health while maintaining proper form and technique.',
                  style: TextStyle(
                    fontSize: width * 0.038,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: height * 0.02),
                Text(
                  isMeal ? 'Ingredients' : 'Exercises Included',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.01),
                if (isMeal) ...[
                  _buildDetailItem('Grilled Chicken Breast', '200g', width),
                  _buildDetailItem('Brown Rice', '1 cup', width),
                  _buildDetailItem('Mixed Vegetables', '150g', width),
                  _buildDetailItem('Olive Oil', '1 tbsp', width),
                ] else ...[
                  _buildDetailItem('Warm-up', '5 minutes', width),
                  _buildDetailItem('Running', '20 minutes', width),
                  _buildDetailItem('Stretching', '5 minutes', width),
                ],
                SizedBox(height: height * 0.02),
                // Action Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (isMeal) {
                      widget.tabController.animateTo(4); // Meals tab
                    } else {
                      _openCamera(); // Open camera for workout
                    }
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
                        isMeal ? 'Add to Meal Plan' : 'Start Workout',
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

  Widget _buildDetailStatItem(String label, String value, double width) {
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

  Widget _buildDetailItem(String name, String details, double width) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 1,
        ),
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
                  Icons.check_circle_outline,
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

  void _showNotifications(double width, double height) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12131A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(width * 0.05),
        constraints: BoxConstraints(
          maxHeight: height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: width * 0.06,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: height * 0.02),
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationItem(
                    icon: Icons.fitness_center,
                    title: 'Workout Reminder',
                    message: 'Time for your evening workout session!',
                    time: '5 min ago',
                    isUnread: true,
                    width: width,
                    height: height,
                  ),
                  _buildNotificationItem(
                    icon: Icons.restaurant,
                    title: 'Meal Plan Ready',
                    message: 'Your weekly meal plan has been generated',
                    time: '1 hour ago',
                    isUnread: true,
                    width: width,
                    height: height,
                  ),
                  _buildNotificationItem(
                    icon: Icons.trending_up,
                    title: 'Weekly Progress',
                    message: 'Great job! You hit 85% of your weekly goal',
                    time: '3 hours ago',
                    isUnread: false,
                    width: width,
                    height: height,
                  ),
                  _buildNotificationItem(
                    icon: Icons.local_fire_department,
                    title: 'Streak Milestone',
                    message: '7 day streak achieved! Keep it going!',
                    time: 'Yesterday',
                    isUnread: false,
                    width: width,
                    height: height,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
    required double width,
    required double height,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.015),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFF1B1D26) : const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? const Color(0xFFCDFF00).withValues(alpha: 0.3) : const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.12,
            height: width * 0.12,
            decoration: BoxDecoration(
              color: const Color(0xFFCDFF00).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFCDFF00),
              size: width * 0.06,
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: width * 0.02,
                        height: width * 0.02,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCDFF00),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: height * 0.005),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCamera() {
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
              'Start Workout Session',
              style: TextStyle(
                fontSize: width * 0.06,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              'Enable camera for form tracking and posture analysis',
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
                          builder: (context) => CameraScreen(
                            workoutName: 'Workout Session',
                          ),
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

