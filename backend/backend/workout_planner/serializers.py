from rest_framework import serializers

FITNESS_GOALS = ['weight_loss', 'muscle_gain', 'endurance', 'flexibility', 'general_fitness']
ACTIVITY_LEVELS = ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extra_active']


class WorkoutGenerateSerializer(serializers.Serializer):
    """
    All fields are optional — if omitted, values are pulled from the user's Firestore profile.
    Provide them here to override the profile or generate a plan without a saved profile.
    """
    fitness_goal = serializers.ChoiceField(choices=FITNESS_GOALS, required=False)
    activity_level = serializers.ChoiceField(choices=ACTIVITY_LEVELS, required=False)
    weight_kg = serializers.FloatField(required=False, min_value=1)
    height_cm = serializers.FloatField(required=False, min_value=1)
    duration_weeks = serializers.IntegerField(required=False, min_value=1, max_value=12, default=4)
