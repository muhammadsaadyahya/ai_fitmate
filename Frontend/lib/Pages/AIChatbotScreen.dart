import 'package:flutter/material.dart';
import 'dart:math';
import '../components/topSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class AIChatbotScreen extends StatefulWidget {
  final String? initialMessage;

  const AIChatbotScreen({Key? key, this.initialMessage}) : super(key: key);

  @override
  State<AIChatbotScreen> createState() => AIChatbotScreenState();
}

class AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      text: "Good morning! Based on your 7-day streak and tight hamstrings from yesterday's run, I suggest a 25-min recovery session. Want me to queue it?",
      isUser: false,
      timestamp: DateTime.now(),
      isPersonalized: true,
    ));

    // Handle initial message if provided
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialMessage!);
      });
    }
  }

  // Public method to send message from external sources
  void sendExternalMessage(String message) {
    if (mounted) {
      _sendMessage(message);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isThinking = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response with thinking delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isThinking = false;
          _messages.add(ChatMessage(
            text: _getAIResponse(text),
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  String _getAIResponse(String userMessage) {
    final responses = [
      "Try a 10-min mobility warmup focusing on ankles and hips. Keep chest up, push knees out, and film a rep for posture analysis. Want the drill list?",
      "Based on your recent activity, I recommend a balanced approach. Focus on form before intensity.",
      "Great question! Let me help you with that. Consider starting with dynamic stretches.",
      "That's a solid goal! I suggest breaking it down into manageable steps.",
      "Perfect timing! Your body should be ready for this challenge.",
    ];
    return responses[Random().nextInt(responses.length)];
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _generateWorkout() {
    setState(() {
      _isGenerating = true;
      _isThinking = true;
    });

    showLoadingSnackBar(context, 'AI is generating your personalized workout...');

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _isThinking = false;
          _messages.add(ChatMessage(
            text: _getMockWorkout(),
            isUser: false,
            timestamp: DateTime.now(),
            isWorkout: true,
          ));
        });
        _scrollToBottom();
        showAwesomeSnackBar(context, 'Workout generated successfully!', ContentType.success);
      }
    });
  }

  String _getMockWorkout() {
    final workouts = [
      "🏋️ Upper Body Strength Workout\n\n"
      "Warm-up (5 min):\n"
      "• Arm circles: 2 sets × 10 reps\n"
      "• Band pull-aparts: 2 sets × 15 reps\n\n"
      "Main Workout (30 min):\n"
      "• Push-ups: 3 sets × 12 reps\n"
      "• Dumbbell rows: 3 sets × 10 reps\n"
      "• Shoulder press: 3 sets × 10 reps\n"
      "• Bicep curls: 3 sets × 12 reps\n"
      "• Tricep dips: 3 sets × 10 reps\n\n"
      "Cool-down (5 min):\n"
      "• Upper body stretches",

      "🏃 HIIT Cardio Blast\n\n"
      "Warm-up (5 min):\n"
      "• Light jog in place\n"
      "• Dynamic stretches\n\n"
      "Main Workout (25 min):\n"
      "• Burpees: 45 sec ON / 15 sec OFF\n"
      "• Mountain climbers: 45 sec ON / 15 sec OFF\n"
      "• Jump squats: 45 sec ON / 15 sec OFF\n"
      "• High knees: 45 sec ON / 15 sec OFF\n"
      "• Plank jacks: 45 sec ON / 15 sec OFF\n"
      "Repeat circuit 4 times\n\n"
      "Cool-down (5 min):\n"
      "• Walking and stretching",

      "🧘 Full Body Mobility Flow\n\n"
      "Duration: 30 minutes\n\n"
      "• Cat-cow stretches: 2 min\n"
      "• Hip circles: 2 min each side\n"
      "• Shoulder dislocations: 2 sets × 10 reps\n"
      "• Deep squat holds: 3 sets × 30 sec\n"
      "• Spinal twists: 2 min each side\n"
      "• Hamstring stretches: 2 min each leg\n"
      "• Pigeon pose: 2 min each side\n"
      "• Child's pose: 3 min\n\n"
      "Focus on breathing and smooth movements.",
    ];
    return workouts[Random().nextInt(workouts.length)];
  }

  void _planMeals() {
    setState(() {
      _isGenerating = true;
      _isThinking = true;
    });

    showLoadingSnackBar(context, 'AI is creating your meal plan...');

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _isThinking = false;
          _messages.add(ChatMessage(
            text: _getMockMealPlan(),
            isUser: false,
            timestamp: DateTime.now(),
            isMealPlan: true,
          ));
        });
        _scrollToBottom();
        showAwesomeSnackBar(context, 'Meal plan created successfully!', ContentType.success);
      }
    });
  }

  String _getMockMealPlan() {
    final mealPlans = [
      "🍽️ High Protein Meal Plan\n\n"
      "Breakfast (7:00 AM):\n"
      "• 3 scrambled eggs\n"
      "• 2 slices whole wheat toast\n"
      "• Avocado slices\n"
      "• Black coffee\n"
      "Calories: 450 | Protein: 28g\n\n"
      "Snack (10:00 AM):\n"
      "• Greek yogurt with berries\n"
      "• Handful of almonds\n"
      "Calories: 250 | Protein: 15g\n\n"
      "Lunch (1:00 PM):\n"
      "• Grilled chicken breast\n"
      "• Quinoa bowl with vegetables\n"
      "• Side salad with olive oil\n"
      "Calories: 550 | Protein: 45g\n\n"
      "Snack (4:00 PM):\n"
      "• Protein shake\n"
      "• Banana\n"
      "Calories: 280 | Protein: 25g\n\n"
      "Dinner (7:00 PM):\n"
      "• Baked salmon\n"
      "• Sweet potato\n"
      "• Steamed broccoli\n"
      "Calories: 520 | Protein: 42g\n\n"
      "Daily Total: 2,050 cal | 155g protein",

      "🥗 Balanced Energy Meal Plan\n\n"
      "Breakfast (7:30 AM):\n"
      "• Oatmeal with banana\n"
      "• Peanut butter\n"
      "• Honey drizzle\n"
      "Calories: 400 | Protein: 12g\n\n"
      "Mid-Morning (10:30 AM):\n"
      "• Apple with almond butter\n"
      "Calories: 200 | Protein: 5g\n\n"
      "Lunch (1:30 PM):\n"
      "• Turkey sandwich on whole grain\n"
      "• Mixed greens salad\n"
      "• Fruit cup\n"
      "Calories: 500 | Protein: 35g\n\n"
      "Afternoon (4:30 PM):\n"
      "• Hummus with veggie sticks\n"
      "• Whole grain crackers\n"
      "Calories: 220 | Protein: 8g\n\n"
      "Dinner (7:30 PM):\n"
      "• Lean beef stir-fry\n"
      "• Brown rice\n"
      "• Mixed vegetables\n"
      "Calories: 580 | Protein: 40g\n\n"
      "Daily Total: 1,900 cal | 100g protein",

      "🌱 Plant-Based Power Plan\n\n"
      "Breakfast (8:00 AM):\n"
      "• Smoothie bowl with:\n"
      "  - Banana, berries, spinach\n"
      "  - Plant protein powder\n"
      "  - Granola topping\n"
      "Calories: 420 | Protein: 25g\n\n"
      "Snack (11:00 AM):\n"
      "• Trail mix\n"
      "• Fresh orange\n"
      "Calories: 260 | Protein: 8g\n\n"
      "Lunch (2:00 PM):\n"
      "• Chickpea Buddha bowl\n"
      "• Tahini dressing\n"
      "• Mixed greens\n"
      "Calories: 480 | Protein: 18g\n\n"
      "Snack (5:00 PM):\n"
      "• Edamame\n"
      "• Rice cakes with avocado\n"
      "Calories: 240 | Protein: 12g\n\n"
      "Dinner (8:00 PM):\n"
      "• Lentil curry\n"
      "• Quinoa\n"
      "• Roasted vegetables\n"
      "Calories: 550 | Protein: 28g\n\n"
      "Daily Total: 1,950 cal | 91g protein",
    ];
    return mealPlans[Random().nextInt(mealPlans.length)];
  }

  void _startPostureScan() {
    showAwesomeSnackBar(context, 'Posture scan feature coming soon!', ContentType.help);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Header matching the design
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI Coach',
                    style: TextStyle(
                      fontSize: width * 0.08,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _messages.clear();
                            _messages.add(ChatMessage(
                              text: "Hello! I'm your AI fitness coach. How can I help you today?",
                              isUser: false,
                              timestamp: DateTime.now(),
                            ));
                          });
                        },
                        child: Text(
                          'New Chat',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      GestureDetector(
                        onTap: () {
                        },
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: width * 0.06,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Compact Quick Suggestion Chips
            Container(
              height: height * 0.04,
              margin: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.01,
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildChip('Daily plan', width, height),
                  SizedBox(width: width * 0.02),
                  _buildChip('Form check', width, height),
                  SizedBox(width: width * 0.02),
                  _buildChip('Recover smarter', width, height),
                  SizedBox(width: width * 0.02),
                  _buildChip('Meal ideas', width, height),
                ],
              ),
            ),

            // Chat Messages (Main Focus - Maximum Space)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.01,
                ),
                itemCount: _messages.length + (_isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isThinking) {
                    return _buildThinkingIndicator(width, height);
                  }
                  return _buildMessageBubble(_messages[index], width, height);
                },
              ),
            ),

            // Compact Quick Actions (Very Small)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.008,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF0B0B0F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCompactAction(
                    'Posture',
                    Icons.center_focus_strong,
                    _startPostureScan,
                    width,
                    height,
                  ),
                  _buildCompactAction(
                    'Workout',
                    Icons.fitness_center,
                    _generateWorkout,
                    width,
                    height,
                  ),
                  _buildCompactAction(
                    'Meals',
                    Icons.restaurant,
                    _planMeals,
                    width,
                    height,
                  ),
                ],
              ),
            ),

            // Compact Message Input
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.01,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF0B0B0F),
                border: Border(
                  top: BorderSide(color: Color(0xFF212229), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0B0F),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF2C2C2E),
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.038,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message FitMate...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF8E8E93),
                            fontSize: width * 0.038,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: height * 0.012,
                          ),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.02),
                  GestureDetector(
                    onTap: () => _sendMessage(_messageController.text),
                    child: Container(
                      padding: EdgeInsets.all(width * 0.03),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCDFF00),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.send,
                        color: const Color(0xFF000000),
                        size: width * 0.05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, double width, double height) {
    return GestureDetector(
      onTap: () => _sendMessage(label),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.025,
          vertical: height * 0.006,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2C2C2E),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: width * 0.028,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, double width, double height) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.01),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: width * 0.75),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.012,
            ),
            decoration: BoxDecoration(
              color: message.isUser
                  ? const Color(0xFFCDFF00)
                  : const Color(0xFF0B0B0F),
              borderRadius: BorderRadius.circular(16),
              border: message.isUser
                  ? null
                  : Border.all(
                      color: const Color(0xFF2C2C2E),
                      width: 1,
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: width * 0.038,
                    fontWeight: FontWeight.w400,
                    color: message.isUser
                        ? const Color(0xFF000000)
                        : Colors.white,
                    height: 1.4,
                  ),
                ),
                if (message.isWorkout || message.isMealPlan)
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.008),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: const Color(0xFFCDFF00),
                          size: width * 0.035,
                        ),
                        SizedBox(width: width * 0.015),
                        Text(
                          'AI Generated',
                          style: TextStyle(
                            fontSize: width * 0.028,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFCDFF00),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (message.isPersonalized)
            Padding(
              padding: EdgeInsets.only(top: height * 0.004, left: width * 0.02),
              child: Text(
                'Today • Personalized insight',
                style: TextStyle(
                  fontSize: width * 0.028,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator(double width, double height) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: width * 0.4),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.015,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0B0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2C2C2E),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI is thinking',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                SizedBox(width: width * 0.02),
                SizedBox(
                  width: width * 0.04,
                  height: width * 0.04,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFCDFF00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAction(
    String label,
    IconData icon,
    VoidCallback onTap,
    double width,
    double height,
  ) {
    return GestureDetector(
      onTap: _isGenerating ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: height * 0.008,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2C2C2E),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFFCDFF00),
              size: width * 0.04,
            ),
            SizedBox(width: width * 0.015),
            Text(
              label,
              style: TextStyle(
                fontSize: width * 0.03,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isPersonalized;
  final bool isWorkout;
  final bool isMealPlan;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isPersonalized = false,
    this.isWorkout = false,
    this.isMealPlan = false,
  });
}

