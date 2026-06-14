import json
import re
import requests
from django.conf import settings

GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions'

BMI_CATEGORIES = [
    (18.5, 'Underweight'),
    (25.0, 'Normal weight'),
    (30.0, 'Overweight'),
    (float('inf'), 'Obese'),
]

GOAL_LABELS = {
    'weight_loss': 'Weight Loss',
    'muscle_gain': 'Muscle Gain',
    'endurance': 'Endurance & Cardio',
    'flexibility': 'Flexibility & Mobility',
    'general_fitness': 'General Fitness',
}

LEVEL_LABELS = {
    'sedentary': 'Sedentary (little to no exercise)',
    'lightly_active': 'Lightly Active (1-2 days/week)',
    'moderately_active': 'Moderately Active (3-4 days/week)',
    'very_active': 'Very Active (5-6 days/week)',
    'extra_active': 'Extra Active (daily intense exercise)',
}


def calculate_bmi(weight_kg: float, height_cm: float) -> tuple[float, str]:
    bmi = round(weight_kg / (height_cm / 100) ** 2, 1)
    category = next(label for threshold, label in BMI_CATEGORIES if bmi < threshold)
    return bmi, category


def _build_prompt(goal: str, activity_level: str, bmi: float, bmi_category: str, duration_weeks: int) -> str:
    return f"""You are a certified personal trainer. Generate a personalized {duration_weeks}-week workout plan.

User Profile:
- Goal: {GOAL_LABELS.get(goal, goal)}
- Fitness Level: {LEVEL_LABELS.get(activity_level, activity_level)}
- BMI: {bmi} ({bmi_category})

Rules:
- Match intensity to the user's fitness level (beginner = fewer sets/reps, higher rest)
- Choose exercises that directly support the stated goal
- Rest days must be included appropriately
- Each exercise must have realistic sets, reps/duration, and rest_seconds

Return ONLY a valid JSON object — no markdown, no explanation — with this exact structure:
{{
  "days_per_week": <integer>,
  "weekly_schedule": {{
    "monday":    {{"focus": "<muscle group or Cardio or Rest>", "exercises": [{{"name": "...", "sets": 3, "reps": "12-15", "rest_seconds": 60, "notes": "..."}}]}},
    "tuesday":   {{"focus": "...", "exercises": [...]}},
    "wednesday": {{"focus": "...", "exercises": [...]}},
    "thursday":  {{"focus": "...", "exercises": [...]}},
    "friday":    {{"focus": "...", "exercises": [...]}},
    "saturday":  {{"focus": "...", "exercises": [...]}},
    "sunday":    {{"focus": "Rest", "exercises": []}}
  }},
  "warm_up": ["<exercise>", "<exercise>", "<exercise>"],
  "cool_down": ["<exercise>", "<exercise>", "<exercise>"],
  "general_tips": ["<tip>", "<tip>", "<tip>"]
}}"""


def _extract_json(text: str) -> dict:
    text = re.sub(r'```(?:json)?', '', text).strip()
    match = re.search(r'\{.*\}', text, re.DOTALL)
    if not match:
        raise ValueError('No JSON object found in Gemini response.')
    return json.loads(match.group())


def generate_workout_plan(goal: str, activity_level: str, weight_kg: float, height_cm: float, duration_weeks: int = 4) -> dict:
    """Call Gemini API and return a structured workout plan dict."""
    bmi, bmi_category = calculate_bmi(weight_kg, height_cm)
    prompt = _build_prompt(goal, activity_level, bmi, bmi_category, duration_weeks)

    resp = requests.post(
        GROQ_API_URL,
        headers={'Authorization': f'Bearer {settings.GROQ_API_KEY}', 'Content-Type': 'application/json'},
        json={'model': 'llama-3.3-70b-versatile', 'messages': [{'role': 'user', 'content': prompt}], 'temperature': 0.4, 'max_tokens': 2000},
        timeout=30,
    )
    resp.raise_for_status()

    plan = _extract_json(resp.json()['choices'][0]['message']['content'])

    plan['bmi'] = bmi
    plan['bmi_category'] = bmi_category
    plan['goal'] = goal
    plan['activity_level'] = activity_level
    plan['duration_weeks'] = duration_weeks

    return plan
