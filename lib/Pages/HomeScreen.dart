import "package:flutter/material.dart";



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Dummy data from backend
  final Map<String, dynamic> userData = {
    'name': 'Alex',
    'greeting': 'Good Morning',
    'message': 'Your adaptive plan is ready. Let\'s crush it!',
    'profileImage':
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
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
      'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
      'progress': 20,
      'type': 'workout',
    },
    {
      'title': 'Protein Boost Lunch',
      'subtitle': 'Meal Plan • 550 kcal',
      'image':
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
      'progress': null,
      'type': 'meal',
    },
    {
      'title': 'Mobility Flow',
      'subtitle': '15 min • Recovery',
      'image':
      'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=800',
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
                SizedBox(height: height * 0.1),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(width, height),
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
                // Your onClick logic here
                setState(() {
                  _selectedIndex = 1;
                });              },
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
            Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: width * 0.065,
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
            backgroundImage: NetworkImage(userData['profileImage']),
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
                  setState(() {
                    _selectedIndex = 1;
                  });
                  // Add your logic here, like navigation or state update
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
                  setState(() {
                    _selectedIndex = 1;
                  });                },
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
                  setState(() {
                    _selectedIndex = 3;
                  });                },
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
    return Container(
      height: height * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.05),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
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
              Colors.black.withOpacity(0.7),
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
                          color: Colors.white.withOpacity(0.8),
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
                            backgroundColor: Colors.white.withOpacity(0.2),
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
                      color: const Color(0xFFCDFF00).withOpacity(0.2),
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
    );
  }

  Widget _buildBottomNavigationBar(double width, double height) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        border: Border(
          top: BorderSide(color: Color(0xFF2C2C2E), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.015,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Dashboard',
                index: 0,
                width: width,
                height: height,
              ),
              _buildNavItem(
                icon: Icons.fitness_center,
                label: 'Workouts',
                index: 1,
                width: width,
                height: height,
              ),
              _buildNavItem(
                icon: Icons.trending_up,
                label: 'Progress',
                index: 2,
                width: width,
                height: height,
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_outline,
                label: 'AI Chatbot',
                index: 3,
                width: width,
                height: height,
              ),
              _buildNavItem(
                icon: Icons.restaurant,
                label: 'Meals',
                index: 4,
                width: width,
                height: height,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required double width,
    required double height,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
            isSelected ? const Color(0xFFCDFF00) : const Color(0xFF8E8E93),
            size: width * 0.07,
          ),
          SizedBox(height: height * 0.005),
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.03,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? const Color(0xFFCDFF00)
                  : const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}