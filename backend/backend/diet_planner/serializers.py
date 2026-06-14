from rest_framework import serializers

FITNESS_GOALS = ['weight_loss', 'muscle_gain', 'endurance', 'flexibility', 'general_fitness']
ACTIVITY_LEVELS = ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extra_active']


class DietGenerateSerializer(serializers.Serializer):
    """
    All fields are optional — missing values are pulled from the user's Firestore profile.
    Provide them here to override or to generate without a saved profile.
    """
    fitness_goal = serializers.ChoiceField(choices=FITNESS_GOALS, required=False)
    activity_level = serializers.ChoiceField(choices=ACTIVITY_LEVELS, required=False)
    gender = serializers.ChoiceField(choices=['male', 'female'], required=False)
    age = serializers.IntegerField(required=False, min_value=1, max_value=120)
    weight_kg = serializers.FloatField(required=False, min_value=1)
    height_cm = serializers.FloatField(required=False, min_value=1)
