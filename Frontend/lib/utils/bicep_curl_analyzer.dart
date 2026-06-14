import 'package:flutter/material.dart';

class BicepCurlAnalysisResult {
  const BicepCurlAnalysisResult({
    required this.reps,
    required this.stage,
    required this.status,
    required this.color,
    required this.elbowAngle,
    required this.angleFeedback,
  });

  final int reps;
  final String stage;
  final String status;
  final Color color;
  final double elbowAngle;
  final String angleFeedback;
}

class BicepCurlAnalyzer {
  int reps = 0;
  String _stage = 'Down';
  double _prevAngle = 0;

  void reset() {
    reps = 0;
    _stage = 'Down';
    _prevAngle = 0;
  }

  BicepCurlAnalysisResult analyze({
    required double elbowAngle,
    required bool badForm,
    required void Function(String) onSpeak,
  }) {
    String currentStatus = "Good Form";
    Color currentColor = Colors.green;
    String angleFeedback = "";

    double angleChange = elbowAngle - _prevAngle;
    bool isExtending = angleChange > 3;
    bool isCurling = angleChange < -3;

    if (!badForm) {
      if (elbowAngle > 160) {
        if (_stage != 'down') {
            // onSpeak("Down");
        }
        _stage = "down";
      }
      if (elbowAngle < 30 && _stage == "down") {
        if (_stage != 'up') {
            reps++;
            onSpeak("$reps");
        }
        _stage = "up";
      }

      if (_stage == "down" && isExtending && elbowAngle < 140) {
        angleFeedback = "KEEP GOING UP";
        onSpeak("Keep going up");
      }

      if (_stage == "up" && isCurling && elbowAngle > 50) {
        angleFeedback = "KEEP GOING DOWN";
        onSpeak("Keep going down");
      }
    }

    _prevAngle = elbowAngle;

    if (badForm) {
      currentStatus = "FIX ELBOW";
      currentColor = Colors.red;
      // onSpeak("Fix your elbow");
    } else if (_stage == "up") {
      currentStatus = "HOLD / DOWN";
    } else {
      currentStatus = "CURL UP";
    }

    return BicepCurlAnalysisResult(
      reps: reps,
      stage: _stage,
      status: currentStatus,
      color: currentColor,
      elbowAngle: elbowAngle,
      angleFeedback: angleFeedback,
    );
  }
}

