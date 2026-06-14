import 'package:flutter/material.dart';
import 'dart:math';

class HighKneesAnalysisResult {
  const HighKneesAnalysisResult({
    required this.reps,
    required this.stage,
    required this.status,
    required this.color,
    required this.streak,
    required this.maxStreak,
    required this.activeAngle,
    required this.leftAngle,
    required this.rightAngle,
  });

  final int reps;
  final String stage;
  final String status;
  final Color color;
  final int streak;
  final int maxStreak;
  final double activeAngle;
  final double leftAngle;
  final double rightAngle;
}

class HighKneesAnalyzer {
  int reps = 0;
  int streak = 0;
  int maxStreak = 0;
  
  String _leftState = 'down';
  String _rightState = 'down';
  
  double _leftHighest = 180.0;
  double _rightHighest = 180.0;
  String? _lastLegLifted;

  String _currentStatus = "Good Form";
  Color _currentColor = Colors.green;

  // Thresholds matching Python
  static const double downThresh = 150.0;
  static const double startThresh = 135.0;
  static const double peakThresh = 100.0;
  static const double lateralLeanThresh = 15.0;
  static const double backwardLeanZThresh = 0.15;
  static const double maxKneeBend3DThresh = 140.0;
  static const double inactiveThresh = 15.0; // diff required to consider a leg active

  void reset() {
    reps = 0;
    streak = 0;
    maxStreak = 0;
    _leftState = 'down';
    _rightState = 'down';
    _leftHighest = 180.0;
    _rightHighest = 180.0;
    _lastLegLifted = null;
    _currentStatus = "Good Form";
    _currentColor = Colors.green;
  }

  void _speakStatus(String status, void Function(String) onSpeak) {
    _currentStatus = status;
    _currentColor = (status == "Good Form") ? Colors.green : Colors.red;
    if (status != "Good Form") {
      onSpeak(status.toLowerCase());
    }
  }

  HighKneesAnalysisResult analyze({
    required double leftAngle,
    required double rightAngle,
    required double leftKneeBend3D,
    required double rightKneeBend3D,
    required double torsoLateralLean,
    required double torsoBackwardLeanZ,
    required void Function(String) onSpeak,
  }) {
    // Reset status to good form at the start of analysis
    _currentStatus = "Good Form";
    _currentColor = Colors.green;
    bool violationFound = false;
    
    // --- LEFT LEG LOGIC ---
    if (_leftState == 'down') {
      if (leftAngle < startThresh) {
        _leftState = 'lifting';
        _leftHighest = leftAngle;
      }
    } else if (_leftState == 'lifting') {
      _leftHighest = min(_leftHighest, leftAngle);
      if (leftAngle < peakThresh) {
        _leftState = 'high';
      } else if (leftAngle > downThresh) {
        _leftState = 'down';
        if (!violationFound) {
          _speakStatus("KNEE HIGHER", onSpeak);
          streak = 0;
          violationFound = true;
        }
      }
    } else if (_leftState == 'high') {
      _leftHighest = min(_leftHighest, leftAngle);
      if (leftAngle > downThresh) {
        _leftState = 'down';
        if (!violationFound) {
          if (_lastLegLifted == 'left' && streak > 0) {
            _speakStatus("WRONG LEG", onSpeak);
            streak = 0;
            violationFound = true;
          } else if (leftKneeBend3D > maxKneeBend3DThresh) {
            _speakStatus("BEND YOUR KNEE", onSpeak);
            streak = 0;
            violationFound = true;
          } else if (torsoBackwardLeanZ > backwardLeanZThresh) {
            _speakStatus("DON'T LEAN BACK", onSpeak);
            streak = 0;
            violationFound = true;
          } else if (torsoLateralLean.abs() > lateralLeanThresh) {
            _speakStatus("KEEP TORSO STRAIGHT", onSpeak);
            streak = 0;
            violationFound = true;
          } else {
            streak++;
            if (streak > maxStreak) maxStreak = streak;
            _lastLegLifted = 'left';
            reps++;
            onSpeak("$streak");
            _currentStatus = "Good Form";
            _currentColor = Colors.green;
          }
        }
      }
    }

    // --- RIGHT LEG LOGIC ---
    if (_rightState == 'down') {
      if (rightAngle < startThresh) {
        _rightState = 'lifting';
        _rightHighest = rightAngle;
      }
    } else if (_rightState == 'lifting') {
      _rightHighest = min(_rightHighest, rightAngle);
      if (rightAngle < peakThresh) {
        _rightState = 'high';
      } else if (rightAngle > downThresh) {
        _rightState = 'down';
        if (!violationFound) {
          _speakStatus("KNEE HIGHER", onSpeak);
          streak = 0;
          violationFound = true;
        }
      }
    } else if (_rightState == 'high') {
      _rightHighest = min(_rightHighest, rightAngle);
      if (rightAngle > downThresh) {
        _rightState = 'down';
        if (!violationFound) {
          if (_lastLegLifted == 'right' && streak > 0) {
            _speakStatus("WRONG LEG", onSpeak);
            streak = 0;
            violationFound = true;
          } else if (rightKneeBend3D > maxKneeBend3DThresh) {
            _speakStatus("BEND YOUR KNEE", onSpeak);
            streak = 0;
            violationFound = true;
          } else if (torsoBackwardLeanZ > backwardLeanZThresh) {
            _speakStatus("DON'T LEAN BACK", onSpeak);
            streak = 0;
            violationFound = true;
          } else if (torsoLateralLean.abs() > lateralLeanThresh) {
            _speakStatus("KEEP TORSO STRAIGHT", onSpeak);
            streak = 0;
            violationFound = true;
          } else {
            streak++;
            if (streak > maxStreak) maxStreak = streak;
            _lastLegLifted = 'right';
            reps++;
            onSpeak("$streak");
            _currentStatus = "Good Form";
            _currentColor = Colors.green;
          }
        }
      }
    }

    // Determine Stage string
    String overallStage = 'Down';
    if (_leftState == 'high' || _rightState == 'high') {
      overallStage = 'High';
    } else if (_leftState == 'lifting' || _rightState == 'lifting') {
      overallStage = 'Lifting';
    }
    
    // Determine active angle for display
    double displayActiveAngle = min(leftAngle, rightAngle);

    return HighKneesAnalysisResult(
      reps: reps,
      stage: overallStage,
      status: _currentStatus,
      color: _currentColor,
      streak: streak,
      maxStreak: maxStreak,
      activeAngle: displayActiveAngle,
      leftAngle: leftAngle,
      rightAngle: rightAngle,
    );
  }
}
