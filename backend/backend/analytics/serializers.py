from rest_framework import serializers


class WorkoutLogSerializer(serializers.Serializer):
    date = serializers.DateField()
    exercise_name = serializers.CharField(max_length=100)
    sets_completed = serializers.IntegerField(min_value=0)
    reps_completed = serializers.IntegerField(min_value=0)
    weight_kg = serializers.FloatField(min_value=0, default=0)
    duration_minutes = serializers.IntegerField(min_value=0, default=0)
    calories_burned = serializers.IntegerField(min_value=0, default=0)
    notes = serializers.CharField(required=False, allow_blank=True, default='')
