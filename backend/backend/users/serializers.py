from rest_framework import serializers


class SignupSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(min_length=6, write_only=True)
    name = serializers.CharField(max_length=100)


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


class UserProfileSerializer(serializers.Serializer):
    uid = serializers.CharField(read_only=True)
    email = serializers.EmailField(read_only=True)
    name = serializers.CharField(required=False, allow_blank=True)
    age = serializers.IntegerField(required=False, min_value=1, max_value=120)
    weight_kg = serializers.FloatField(required=False, min_value=1)
    height_cm = serializers.FloatField(required=False, min_value=1)
    gender = serializers.ChoiceField(choices=['male', 'female'], required=False)
    fitness_goal = serializers.ChoiceField(
        choices=['weight_loss', 'muscle_gain', 'endurance', 'flexibility', 'general_fitness'],
        required=False,
    )
    activity_level = serializers.ChoiceField(
        choices=['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extra_active'],
        required=False,
    )
