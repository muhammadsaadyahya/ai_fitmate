import 'package:ai_fitmate/components/topSnackBar.dart';
import 'package:flutter/material.dart';
import 'AIChatbotScreen.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
class MealsScreen extends StatefulWidget {
  final TabController? tabController;
  final GlobalKey<AIChatbotScreenState>? aiChatbotKey;

  const MealsScreen({
    Key? key,
    this.tabController,
    this.aiChatbotKey,
  }) : super(key: key);

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  int _selectedPlanIndex = 0; // 0: Today, 1: Tomorrow, 2: Week, 3: Groceries

  final List<String> planOptions = ['Today', 'Tomorrow', 'Week', 'Groceries'];

  // Mock nutrition data
  final Map<String, dynamic> nutritionData = {
    'target': 2100,
    'protein': 35,
    'carbs': 40,
    'fat': 25,
    'consumed': 820,
    'remaining': 1280,
  };

  // Mock meal suggestions for different days
  final Map<String, List<Map<String, dynamic>>> mealsByPlan = {
    'Today': [
      {
        'name': 'Greek Yogurt Bowl',
        'type': 'Breakfast',
        'calories': 420,
        'protein': 32,
        'image': 'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=400&h=400&fit=crop',
      },
      {
        'name': 'Chicken Quinoa Salad',
        'type': 'Lunch',
        'calories': 560,
        'protein': 45,
        'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=400&fit=crop',
      },
      {
        'name': 'Salmon Veggie Bowl',
        'type': 'Dinner',
        'calories': 620,
        'protein': 38,
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=400&fit=crop',
      },
    ],
    'Tomorrow': [
      {
        'name': 'Protein Pancakes',
        'type': 'Breakfast',
        'calories': 450,
        'protein': 35,
        'image': 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=400&h=400&fit=crop',
      },
      {
        'name': 'Turkey Wrap & Veggies',
        'type': 'Lunch',
        'calories': 520,
        'protein': 42,
        'image': 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=400&h=400&fit=crop',
      },
      {
        'name': 'Beef Stir-Fry',
        'type': 'Dinner',
        'calories': 580,
        'protein': 48,
        'image': 'https://images.unsplash.com/photo-1603073524119-c39e5bbedca4?w=400&h=400&fit=crop',
      },
    ],
    'Week': [
      {
        'name': 'Meal Prep Sunday',
        'type': 'Batch Cook',
        'calories': 3500,
        'protein': 250,
        'image': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=400&fit=crop',
      },
      {
        'name': 'Weekly Protein Pack',
        'type': '7 Days',
        'calories': 14700,
        'protein': 980,
        'image': 'https://images.unsplash.com/photo-1606787366850-de6330128bfc?w=400&h=400&fit=crop',
      },
      {
        'name': 'Meal Planning Guide',
        'type': 'Full Week',
        'calories': 14700,
        'protein': 1050,
        'image': 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400&h=400&fit=crop',
      },
    ],
    'Groceries': [
      {
        'name': 'Weekly Grocery List',
        'type': 'Shopping List',
        'calories': 0,
        'protein': 0,
        'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=400&fit=crop',
      },
      {
        'name': 'Protein Sources',
        'type': 'Essentials',
        'calories': 0,
        'protein': 0,
        'image': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400&h=400&fit=crop',
      },
      {
        'name': 'Fresh Produce',
        'type': 'Weekly Haul',
        'calories': 0,
        'protein': 0,
        'image': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=400&fit=crop',
      },
    ],
  };

  List<Map<String, dynamic>> get suggestedMeals {
    return mealsByPlan[planOptions[_selectedPlanIndex]] ??
        mealsByPlan['Today']!;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    final height = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.02),
                _buildHeader(width, height),
                SizedBox(height: height * 0.025),
                _buildNutritionCard(width, height),
                SizedBox(height: height * 0.025),
                _buildPlanOptions(width, height),
                SizedBox(height: height * 0.025),
                _buildSuggestedMeals(width, height),
                SizedBox(height: height * 0.025),
                _buildSmartGenerator(width, height),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Meals',
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
                _showPreferencesDialog(width, height);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.01,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1D26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2C2C2E),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.03),
            GestureDetector(
              onTap: () {
                _showSettingsDialog(width, height);
              },
              child: Icon(
                Icons.tune,
                color: Colors.white,
                size: width * 0.06,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionCard(double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF212229),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: width * 0.08,
                  ),
                  SizedBox(width: width * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Nutrition",
                        style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        'Target ${nutritionData['target']} kcal • ${nutritionData['protein']}P / ${nutritionData['carbs']}C / ${nutritionData['fat']}F',
                        style: TextStyle(
                          fontSize: width * 0.032,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  _showLogMealDialog(width, height);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCDFF00),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Log',
                    style: TextStyle(
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.02),
          Row(
            children: [
              Expanded(
                child: _buildNutritionStat(
                  'Consumed',
                  '${nutritionData['consumed']} kcal',
                  width,
                  height,
                ),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: _buildNutritionStat(
                  'Remaining',
                  '${nutritionData['remaining']} kcal',
                  width,
                  height,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStat(String label, String value, double width,
      double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.032,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
            ),
          ),
          SizedBox(height: height * 0.005),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOptions(double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan options',
          style: TextStyle(
            fontSize: width * 0.04,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8E8E93),
          ),
        ),
        SizedBox(height: height * 0.015),
        Row(
          children: List.generate(
            planOptions.length,
                (index) =>
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: index < planOptions.length - 1
                            ? width * 0.02
                            : 0),
                    child: _buildPlanChip(
                        planOptions[index], index, width, height),
                  ),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanChip(String label, int index, double width, double height) {
    bool isSelected = _selectedPlanIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.015,
          vertical: height * 0.01,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCDFF00) : const Color(0xFF1B1D26),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFCDFF00) : const Color(
                0xFF2C2C2E),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: width * 0.029,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF000000) : Colors.white,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedMeals(double width, double height) {
    final isGroceries = planOptions[_selectedPlanIndex] == 'Groceries';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isGroceries ? 'Shopping lists' : 'Suggested meals',
          style: TextStyle(
            fontSize: width * 0.04,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8E8E93),
          ),
        ),
        SizedBox(height: height * 0.015),
        ...suggestedMeals.map((meal) =>
            _buildMealCard(meal, width, height, isGroceries)),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, double width, double height,
      bool isGroceries) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.015),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF212229),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              meal['image'],
              width: width * 0.2,
              height: width * 0.2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width * 0.2,
                  height: width * 0.2,
                  color: const Color(0xFF1B1D26),
                  child: Icon(
                    Icons.restaurant,
                    color: const Color(0xFFCDFF00),
                    size: width * 0.1,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: width * 0.2,
                  height: width * 0.2,
                  color: const Color(0xFF1B1D26),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFFCDFF00),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['name'],
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  isGroceries
                      ? meal['type']
                      : '${meal['type']} • ${meal['calories']} kcal • ${meal['protein']}g protein',
                  style: TextStyle(
                    fontSize: width * 0.032,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                SizedBox(height: height * 0.01),
                if (isGroceries)
                  GestureDetector(
                    onTap: () {
                      _showGroceryList(meal, width, height);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCDFF00),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'View List',
                        style: TextStyle(
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _swapMeal(meal, width, height);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03,
                            vertical: height * 0.008,
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
                            'Swap',
                            style: TextStyle(
                              fontSize: width * 0.03,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      GestureDetector(
                        onTap: () {
                          // View details - simulate backend
                          _showMealDetails(meal, width, height);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03,
                            vertical: height * 0.008,
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
                            'Details',
                            style: TextStyle(
                              fontSize: width * 0.03,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (!isGroceries)
            GestureDetector(
              onTap: () {
                // Add meal - simulate backend
                _addMealToLog(meal);
              },
              child: Container(
                padding: EdgeInsets.all(width * 0.02),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1D26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2C2C2E),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: width * 0.06,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmartGenerator(double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart generator',
          style: TextStyle(
            fontSize: width * 0.04,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8E8E93),
          ),
        ),
        SizedBox(height: height * 0.015),
        Container(
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: const Color(0xFF12131A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF212229),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: const Color(0xFFCDFF00),
                size: width * 0.08,
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate meals with AI',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: height * 0.005),
                    Text(
                      'Use goals, budget, and prep time to create a tailored plan',
                      style: TextStyle(
                        fontSize: width * 0.032,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: width * 0.03),
              GestureDetector(
                onTap: () {
                  // Navigate to AI Chatbot with meal generation context
                  _generateMealsWithAI();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.012,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCDFF00),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Generate',
                    style: TextStyle(
                      fontSize: width * 0.038,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _generateMealsWithAI() {
    // Mock user preferences data
    final String goals = "Muscle gain and fat loss";
    final String budget = "\$50-75 per week";
    final String prepTime = "30-45 minutes per meal";
    final String dietaryRestrictions = "None";
    final int targetCalories = nutritionData['target'];
    final String macros = "${nutritionData['protein']}P / ${nutritionData['carbs']}C / ${nutritionData['fat']}F";

    // Construct detailed message with user preferences
    final String detailedMessage = '''Generate a personalized meal plan for me with the following details:

🎯 Goals: $goals
💰 Budget: $budget
⏰ Prep Time: $prepTime
🥗 Dietary Restrictions: $dietaryRestrictions
📊 Target: $targetCalories kcal/day
🔢 Macros: $macros

Please create a detailed meal plan with breakfast, lunch, dinner, and snacks that fits these requirements.''';

    // Navigate to AI Chatbot and send the message
    if (widget.tabController != null) {
      widget.tabController!.animateTo(3); // Navigate to AI Chatbot tab

      // Wait for tab animation to complete, then send message
      Future.delayed(const Duration(milliseconds: 300), () {
        if (widget.aiChatbotKey != null &&
            widget.aiChatbotKey!.currentState != null) {
          widget.aiChatbotKey!.currentState!.sendExternalMessage(
              detailedMessage);
        }
      });

      // Show a snackbar to indicate the action
      showLoadingSnackBar(context, 'Sending your preferences to AI Coach...');
    }
  }

  void _showMealDetails(Map<String, dynamic> meal, double width,
      double height) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12131A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) =>
                SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    padding: EdgeInsets.all(width * 0.05),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            meal['image'],
                            width: double.infinity,
                            height: height * 0.25,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          meal['name'],
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          '${meal['type']} • ${meal['calories']} kcal • ${meal['protein']}g protein',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          'Nutritional Information',
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        _buildNutritionRow(
                            'Protein', '${meal['protein']}g', width),
                        _buildNutritionRow('Carbs', '45g', width),
                        _buildNutritionRow('Fat', '12g', width),
                        _buildNutritionRow('Fiber', '8g', width),
                        SizedBox(height: height * 0.02),
                        Text(
                          'Ingredients',
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          '• Greek yogurt (200g)\n• Blueberries (50g)\n• Granola (30g)\n• Honey (1 tbsp)\n• Almonds (20g)',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E8E93),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  _addMealToLog(meal);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: height * 0.015),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCDFF00),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Add to Log',
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF000000),
                                      ),
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
                ),
          ),
    );
  }

  Widget _buildNutritionRow(String label, String value, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _addMealToLog(Map<String, dynamic> meal) {
    // Simulate backend adding meal to log
    showAwesomeSnackBar(
      context,
      '${meal['name']} added to your meal log!',
      ContentType.success,
    );

    setState(() {
      // Update consumed calories
      nutritionData['consumed'] =
          (nutritionData['consumed'] as int) + (meal['calories'] as int);
      nutritionData['remaining'] =
          (nutritionData['remaining'] as int) - (meal['calories'] as int);
    });
  }

  void _showLogMealDialog(double width, double height) {
    final TextEditingController mealNameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12131A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(width * 0.05),
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
                    'Log a Meal',
                    style: TextStyle(
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: mealNameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Meal Name',
                      labelStyle: TextStyle(color: const Color(0xFF8E8E93)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFF2C2C2E)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFCDFF00)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  TextField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Calories',
                      labelStyle: TextStyle(color: const Color(0xFF8E8E93)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFF2C2C2E)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFCDFF00)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: height * 0.015),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B1D26),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFF2C2C2E)),
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
                            if (mealNameController.text.isNotEmpty &&
                                caloriesController.text.isNotEmpty) {
                              final calories = int.tryParse(
                                  caloriesController.text) ?? 0;
                              Navigator.pop(context);
                              _addMealToLog({
                                'name': mealNameController.text,
                                'calories': calories,
                                'protein': 0,
                                'type': 'Custom',
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: height * 0.015),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCDFF00),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Log Meal',
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF000000),
                                ),
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
          ),
    );
  }

  void _swapMeal(Map<String, dynamic> currentMeal, double width,
      double height) {
    // Mock alternative meals
    final List<Map<String, dynamic>> alternativeMeals = [
      {
        'name': 'Oatmeal Power Bowl',
        'type': 'Breakfast',
        'calories': 380,
        'protein': 28,
        'image': 'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=400&h=400&fit=crop',
      },
      {
        'name': 'Avocado Toast',
        'type': 'Breakfast',
        'calories': 350,
        'protein': 25,
        'image': 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=400&h=400&fit=crop',
      },
      {
        'name': 'Protein Pancakes',
        'type': 'Breakfast',
        'calories': 450,
        'protein': 35,
        'image': 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=400&h=400&fit=crop',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12131A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) =>
                SingleChildScrollView(
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
                        Text(
                          'Swap ${currentMeal['name']}',
                          style: TextStyle(
                            fontSize: width * 0.055,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          'Choose an alternative meal',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        ...alternativeMeals.map((meal) =>
                            _buildSwapOption(meal, currentMeal, width, height)),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildSwapOption(Map<String, dynamic> newMeal,
      Map<String, dynamic> oldMeal, double width, double height) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          final index = suggestedMeals.indexWhere((meal) =>
          meal['name'] == oldMeal['name']);
          if (index != -1) {
            suggestedMeals[index] = newMeal;
          }
        });
        showAwesomeSnackBar(
          context,
          'Swapped to ${newMeal['name']}!',
          ContentType.success,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: height * 0.015),
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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                newMeal['image'],
                width: width * 0.15,
                height: width * 0.15,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    newMeal['name'],
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    '${newMeal['calories']} kcal • ${newMeal['protein']}g protein',
                    style: TextStyle(
                      fontSize: width * 0.032,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF8E8E93),
              size: width * 0.04,
            ),
          ],
        ),
      ),
    );
  }

  void _showPreferencesDialog(double width, double height) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12131A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          Container(
            padding: EdgeInsets.all(width * 0.05),
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
                  'Dietary Preferences',
                  style: TextStyle(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.02),
                _buildPreferenceItem('Vegetarian', Icons.eco, width, height),
                _buildPreferenceItem(
                    'Vegan', Icons.local_florist, width, height),
                _buildPreferenceItem('Gluten-Free', Icons.grain, width, height),
                _buildPreferenceItem(
                    'Dairy-Free', Icons.no_meals, width, height),
                _buildPreferenceItem(
                    'Keto', Icons.fitness_center, width, height),
                _buildPreferenceItem('Paleo', Icons.restaurant, width, height),
                SizedBox(height: height * 0.02),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showAwesomeSnackBar(
                      context,
                      'Preferences saved!',
                      ContentType.success,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: height * 0.015),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDFF00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Save Preferences',
                        style: TextStyle(
                          fontSize: width * 0.04,
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
    );
  }

  Widget _buildPreferenceItem(String label, IconData icon, double width,
      double height) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.01),
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
        children: [
          Icon(
            icon,
            color: const Color(0xFFCDFF00),
            size: width * 0.06,
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Icon(
            Icons.check_circle_outline,
            color: const Color(0xFF8E8E93),
            size: width * 0.06,
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(double width, double height) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12131A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          Container(
            padding: EdgeInsets.all(width * 0.05),
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
                  'Meal Settings',
                  style: TextStyle(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.02),
                _buildSettingItem(
                    'Daily Calorie Target', '${nutritionData['target']} kcal',
                    Icons.local_fire_department, width, height),
                _buildSettingItem('Meals Per Day', '3 meals + 2 snacks',
                    Icons.restaurant_menu, width, height),
                _buildSettingItem(
                    'Prep Time Limit', '30-45 minutes', Icons.timer, width,
                    height),
                _buildSettingItem(
                    'Budget Per Week', '\$50-75', Icons.attach_money, width,
                    height),
                _buildSettingItem(
                    'Notifications', 'Enabled', Icons.notifications, width,
                    height),
                SizedBox(height: height * 0.02),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showAwesomeSnackBar(
                      context,
                      'Settings updated!',
                      ContentType.success,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: height * 0.015),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDFF00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: width * 0.04,
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
    );
  }

  Widget _buildSettingItem(String label, String value, IconData icon,
      double width, double height) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.01),
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
        children: [
          Icon(
            icon,
            color: const Color(0xFFCDFF00),
            size: width * 0.06,
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.003),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: width * 0.032,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: const Color(0xFF8E8E93),
            size: width * 0.04,
          ),
        ],
      ),
    );
  }

  void _showGroceryList(Map<String, dynamic> groceryList, double width,
      double height) {
    final Map<String, List<String>> mockGroceryItems = {
      'Weekly Grocery List': [
        '🥚 Eggs (2 dozen)',
        '🥛 Greek Yogurt (1kg)',
        '🍗 Chicken Breast (2kg)',
        '🐟 Salmon Fillets (800g)',
        '🥗 Mixed Salad Greens',
        '🥑 Avocados (6)',
        '🍌 Bananas (12)',
        '🥔 Sweet Potatoes (2kg)',
        '🍚 Brown Rice (1kg)',
        '🌾 Quinoa (500g)',
      ],
      'Protein Sources': [
        '🥩 Lean Ground Beef (1kg)',
        '🍗 Chicken Thighs (1.5kg)',
        '🦃 Turkey Breast (1kg)',
        '🐟 Tuna Cans (6 pack)',
        '🥚 Egg Whites (1L)',
        '🥛 Protein Powder (1 tub)',
        '🧀 Cottage Cheese (500g)',
        '🫘 Black Beans (3 cans)',
        '🥜 Almonds (500g)',
        '🌰 Mixed Nuts (400g)',
      ],
      'Fresh Produce': [
        '🥬 Spinach (2 bags)',
        '🥦 Broccoli (3 heads)',
        '🫑 Bell Peppers (6)',
        '🥕 Carrots (1kg)',
        '🍅 Cherry Tomatoes (500g)',
        '🥒 Cucumbers (4)',
        '🧅 Red Onions (6)',
        '🧄 Garlic (2 bulbs)',
        '🍋 Lemons (6)',
        '🫐 Blueberries (3 packs)',
      ],
    };

    final items = mockGroceryItems[groceryList['name']] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12131A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) =>
                SingleChildScrollView(
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
                        Text(
                          groceryList['name'],
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          '${items.length} items',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        ...items.map((item) =>
                            Container(
                              margin: EdgeInsets.only(bottom: height * 0.01),
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
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: const Color(0xFF8E8E93),
                                    size: width * 0.05,
                                  ),
                                  SizedBox(width: width * 0.03),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: width * 0.038,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(height: height * 0.02),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          showAwesomeSnackBar(
                            context,
                            'Grocery list exported!',
                            ContentType.success,
                          );
                        },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: height * 0.015),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCDFF00),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Export List',
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF000000),
                                      ),
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
                ),
          ),
    );
  }
}
