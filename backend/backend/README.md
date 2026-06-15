# AI FitMate Django Backend

This is the main Django backend for the AI FitMate application.

## Structure
- `fitmate`: Main project settings.
- `users`: User authentication and management.
- `analytics`: Analytics for user workouts and exercises.
- `chatbot`: AI chatbot integration.
- `diet_planner`: Diet planning features.
- `workout_planner`: Workout planning features.

## Setup
1. Create a virtual environment and activate it.
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run migrations:
   ```bash
   python manage.py migrate
   ```
4. Run the server:
   ```bash
   python manage.py runserver
   ```
