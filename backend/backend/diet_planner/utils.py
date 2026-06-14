import json
import re
import requests
from django.conf import settings

GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions'

ACTIVITY_MULTIPLIERS = {
    'sedentary': 1.2,
    'lightly_active': 1.375,
    'moderately_active': 1.55,
    'very_active': 1.725,
    'extra_active': 1.9,
}

GOAL_CALORIE_DELTA = {
    'weight_loss': -500,
    'muscle_gain': 300,
    'endurance': 200,
    'flexibility': 0,
    'general_fitness': 0,
}

MACRO_RATIOS = {
    'weight_loss':     (0.40, 0.35, 0.25),
    'muscle_gain':     (0.30, 0.45, 0.25),
    'endurance':       (0.20, 0.55, 0.25),
    'flexibility':     (0.25, 0.45, 0.30),
    'general_fitness': (0.25, 0.45, 0.30),
}

GOAL_LABELS = {
    'weight_loss': 'Weight Loss',
    'muscle_gain': 'Muscle Gain',
    'endurance': 'Endurance & Cardio',
    'flexibility': 'Flexibility & Mobility',
    'general_fitness': 'General Fitness',
}

LEVEL_LABELS = {
    'sedentary': 'Sedentary',
    'lightly_active': 'Lightly Active',
    'moderately_active': 'Moderately Active',
    'very_active': 'Very Active',
    'extra_active': 'Extra Active',
}


def calculate_tdee(gender: str, age: int, weight_kg: float, height_cm: float, activity_level: str) -> int:
    """Mifflin-St Jeor BMR → TDEE."""
    if gender == 'male':
        bmr = (10 * weight_kg) + (6.25 * height_cm) - (5 * age) + 5
    else:
        bmr = (10 * weight_kg) + (6.25 * height_cm) - (5 * age) - 161
    return round(bmr * ACTIVITY_MULTIPLIERS[activity_level])


def calculate_targets(goal: str, tdee: int) -> dict:
    calories = max(1200, tdee + GOAL_CALORIE_DELTA.get(goal, 0))
    p_ratio, c_ratio, f_ratio = MACRO_RATIOS.get(goal, (0.25, 0.45, 0.30))
    return {
        'daily_calories': calories,
        'protein_g': round((calories * p_ratio) / 4),
        'carbs_g': round((calories * c_ratio) / 4),
        'fat_g': round((calories * f_ratio) / 9),
    }


def _build_prompt(goal: str, activity_level: str, targets: dict) -> str:
    return f"""You are a registered dietitian. Create a personalized 7-day diet plan.

User Targets:
- Goal: {GOAL_LABELS.get(goal, goal)}
- Activity Level: {LEVEL_LABELS.get(activity_level, activity_level)}
- Daily Calories: {targets['daily_calories']} kcal
- Protein: {targets['protein_g']}g | Carbs: {targets['carbs_g']}g | Fat: {targets['fat_g']}g

Rules:
- All meals must fit within the daily calorie and macro targets
- Use realistic, commonly available foods
- Include a variety of nutrients across the week
- Each meal must include estimated calories

Return ONLY a valid JSON object — no markdown, no explanation — with this exact structure:
{{
  "daily_meal_plan": {{
    "breakfast": {{
      "name": "<meal name>",
      "foods": [
        {{"item": "<food>", "quantity": "<amount>", "calories": <int>, "protein_g": <int>, "carbs_g": <int>, "fat_g": <int>}}
      ],
      "total_calories": <int>
    }},
    "morning_snack": {{"name": "<snack name>", "foods": [...], "total_calories": <int>}},
    "lunch":         {{"name": "<meal name>",  "foods": [...], "total_calories": <int>}},
    "evening_snack": {{"name": "<snack name>", "foods": [...], "total_calories": <int>}},
    "dinner":        {{"name": "<meal name>",  "foods": [...], "total_calories": <int>}}
  }},
  "weekly_variety": {{
    "monday": "<theme>", "tuesday": "<theme>", "wednesday": "<theme>",
    "thursday": "<theme>", "friday": "<theme>", "saturday": "<theme>", "sunday": "<theme>"
  }},
  "foods_to_avoid": ["<food>", "<food>", "<food>"],
  "hydration_liters": <float>,
  "supplements": ["<supplement if needed>"],
  "general_tips": ["<tip>", "<tip>", "<tip>"]
}}"""


def _extract_json(text: str) -> dict:
    text = re.sub(r'```(?:json)?', '', text).strip()
    match = re.search(r'\{.*\}', text, re.DOTALL)
    if not match:
        raise ValueError('No JSON object found in Gemini response.')
    return json.loads(match.group())


def generate_diet_plan(goal: str, activity_level: str, gender: str, age: int, weight_kg: float, height_cm: float) -> dict:
    """Call Gemini API and return a structured diet plan dict with caloric targets."""
    tdee = calculate_tdee(gender, age, weight_kg, height_cm, activity_level)
    targets = calculate_targets(goal, tdee)
    prompt = _build_prompt(goal, activity_level, targets)

    resp = requests.post(
        GROQ_API_URL,
        headers={'Authorization': f'Bearer {settings.GROQ_API_KEY}', 'Content-Type': 'application/json'},
        json={'model': 'llama-3.3-70b-versatile', 'messages': [{'role': 'user', 'content': prompt}], 'temperature': 0.4, 'max_tokens': 2500},
        timeout=30,
    )
    resp.raise_for_status()

    plan = _extract_json(resp.json()['choices'][0]['message']['content'])

    plan['tdee'] = tdee
    plan['daily_calories_target'] = targets['daily_calories']
    plan['macros_target'] = {
        'protein_g': targets['protein_g'],
        'carbs_g': targets['carbs_g'],
        'fat_g': targets['fat_g'],
    }
    plan['goal'] = goal
    plan['activity_level'] = activity_level

    return plan
