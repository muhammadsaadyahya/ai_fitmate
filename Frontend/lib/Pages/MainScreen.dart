import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'ProgressScreen.dart';
import 'AIChatbotScreen.dart';
import 'MealsScreen.dart';
import 'WorkoutsScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<AIChatbotScreenState> _aiChatbotKey = GlobalKey<AIChatbotScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeScreen(tabController: _tabController),
          const WorkoutsScreen(),
          const ProgressScreen(),
          AIChatbotScreen(key: _aiChatbotKey),
          MealsScreen(
            tabController: _tabController,
            aiChatbotKey: _aiChatbotKey,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12131A),
          border: Border(
            top: BorderSide(color: Color(0xFF212229), width: 1),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFCDFF00),
          indicatorWeight: 3,
          labelColor: const Color(0xFFCDFF00),
          unselectedLabelColor: const Color(0xFF8E8E93),
          labelPadding: const EdgeInsets.symmetric(vertical: 8),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.home),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(Icons.fitness_center),
              text: 'Workouts',
            ),
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Progress',
            ),
            Tab(
              icon: Icon(Icons.chat_bubble_outline),
              text: 'AI Chatbot',
            ),
            Tab(
              icon: Icon(Icons.restaurant),
              text: 'Meals',
            ),
          ],
        ),
      ),
    );
  }
}

