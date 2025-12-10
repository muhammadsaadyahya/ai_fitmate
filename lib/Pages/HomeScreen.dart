import "package:flutter/material.dart";



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
                SizedBox(height: size.height * 0.025),
                _buildGreetingCard(context, isSmallScreen),
                SizedBox(height: size.height * 0.025),
                _buildStatsCards(context, size, isSmallScreen),
                SizedBox(height: size.height * 0.025),
                _buildProgressCard(context, isSmallScreen),
                SizedBox(height: size.height * 0.03),
                _buildQuickActions(context, isSmallScreen),
                SizedBox(height: size.height * 0.03),
                _buildRecommendedSection(context, size, isSmallScreen),
                SizedBox(height: size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isSmallScreen),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'DASHBOARD',
          style: TextStyle(
            fontSize: isSmallScreen ? 26 : 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
                vertical: isSmallScreen ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFCDFF00),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'Start',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: isSmallScreen ? 22 : 26,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreetingCard(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isSmallScreen ? 28 : 32,
            backgroundImage: const NetworkImage(
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, Alex',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your adaptive plan is ready. Let\'s crush it!',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 15,
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

  Widget _buildStatsCards(BuildContext context, Size size, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Active Streak',
            value: '7 days',
            subtitle: 'Keep it up!',
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Today\nCalories',
            value: '1,250',
            subtitle: 'of 2,100 goal',
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Weekly\nMinutes',
            value: '142',
            subtitle: 'of 180 target',
            isSmallScreen: isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: const Color(0xFF8E8E93),
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 13,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C2C2E)),
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
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your plan completion',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 15,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: isSmallScreen ? 80 : 100,
                  height: isSmallScreen ? 80 : 100,
                  child: CircularProgressIndicator(
                    value: 0.55,
                    strokeWidth: isSmallScreen ? 8 : 10,
                    backgroundColor: const Color(0xFF2C2C2E),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFCDFF00),
                    ),
                  ),
                ),
                Text(
                  '55%',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
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

  Widget _buildQuickActions(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8E8E93),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.fitness_center,
                label: 'Start Workout',
                isSmallScreen: isSmallScreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.center_focus_strong,
                label: 'Posture Coach',
                isSmallScreen: isSmallScreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Ask AI',
                isSmallScreen: isSmallScreen,
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
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isSmallScreen ? 28 : 32,
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(
      BuildContext context, Size size, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended For You',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8E8E93),
          ),
        ),
        const SizedBox(height: 16),
        _buildRecommendedCard(
          image:
          'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
          title: 'Endurance Run',
          subtitle: '30 min • Low Impact',
          progress: 0.20,
          isSmallScreen: isSmallScreen,
        ),
        const SizedBox(height: 16),
        _buildRecommendedCard(
          image:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
          title: 'Protein Boost Lunch',
          subtitle: 'Meal Plan • 550 kcal',
          progress: null,
          hasCheckIcon: true,
          isSmallScreen: isSmallScreen,
        ),
        const SizedBox(height: 16),
        _buildRecommendedCard(
          image:
          'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=800',
          title: 'Mobility Flow',
          subtitle: '15 min • Recovery',
          progress: 0.0,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildRecommendedCard({
    required String image,
    required String title,
    required String subtitle,
    double? progress,
    bool hasCheckIcon = false,
    required bool isSmallScreen,
  }) {
    return Container(
      height: isSmallScreen ? 180 : 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
        padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
                          fontSize: isSmallScreen ? 22 : 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 15,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (progress != null)
                  SizedBox(
                    width: isSmallScreen ? 50 : 60,
                    height: isSmallScreen ? 50 : 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: isSmallScreen ? 50 : 60,
                          height: isSmallScreen ? 50 : 60,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 5,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFCDFF00),
                            ),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFCDFF00),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (hasCheckIcon)
                  Container(
                    width: isSmallScreen ? 50 : 60,
                    height: isSmallScreen ? 50 : 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDFF00).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Color(0xFFCDFF00),
                      size: 28,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isSmallScreen) {
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
            horizontal: isSmallScreen ? 8 : 16,
            vertical: isSmallScreen ? 8 : 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Dashboard',
                index: 0,
                isSmallScreen: isSmallScreen,
              ),
              _buildNavItem(
                icon: Icons.fitness_center,
                label: 'Workouts',
                index: 1,
                isSmallScreen: isSmallScreen,
              ),
              _buildNavItem(
                icon: Icons.trending_up,
                label: 'Progress',
                index: 2,
                isSmallScreen: isSmallScreen,
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_outline,
                label: 'AI Chatbot',
                index: 3,
                isSmallScreen: isSmallScreen,
              ),
              _buildNavItem(
                icon: Icons.restaurant,
                label: 'Meals',
                index: 4,
                isSmallScreen: isSmallScreen,
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
    required bool isSmallScreen,
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
            color: isSelected ? const Color(0xFFCDFF00) : const Color(0xFF8E8E93),
            size: isSmallScreen ? 24 : 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFFCDFF00) : const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}
