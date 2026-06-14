import 'package:flutter/material.dart';

class SquatAnalysisResult {
  const SquatAnalysisResult({
    required this.reps,
    required this.improperReps,
    required this.stage,
    required this.status,
    required this.color,
    required this.hipVertAngle,
    required this.kneeVertAngle,
    required this.ankleVertAngle,
  });

  final int reps;
  final int improperReps;
  final String stage;
  final String status;
  final Color color;
  final double hipVertAngle;
  final double kneeVertAngle;
  final double ankleVertAngle;
}

class SquatAnalyzer {
  int reps = 0;
  int improperReps = 0;
  String _stage = 'Up';
  List<String> _stateSeq = [];
  bool _incorrectPosture = false;

  void reset() {
    reps = 0;
    improperReps = 0;
    _stage = 'Up';
    _stateSeq = [];
    _incorrectPosture = false;
  }

  SquatAnalysisResult analyze({
    required double hipVertAngle,
    required double kneeVertAngle,
    required double ankleVertAngle,
    required void Function(String) onSpeak,
  }) {
    String currentStatus = "Good Form";
    Color currentColor = Colors.green;

    String? state;
    if (kneeVertAngle >= 0 && kneeVertAngle <= 32) {
      state = 's1';
    } else if (kneeVertAngle >= 35 && kneeVertAngle <= 65) {
      state = 's2';
    } else if (kneeVertAngle >= 70 && kneeVertAngle <= 95) {
      state = 's3';
    }

    if (state == 's2') {
      if ((!_stateSeq.contains('s3') && _stateSeq.where((e) => e == 's2').isEmpty) ||
          (_stateSeq.contains('s3') && _stateSeq.where((e) => e == 's2').length == 1)) {
        _stateSeq.add(state!);
      }
    } else if (state == 's3') {
      if (!_stateSeq.contains('s3') && _stateSeq.contains('s2')) {
        _stateSeq.add(state!);
      }
    }

    if (state == 's1') {
      _stage = "Up";
      if (_stateSeq.length == 3 && !_incorrectPosture) {
        reps++;
        onSpeak("$reps");
        currentStatus = "Good Form";
      } else if (_stateSeq.isNotEmpty) {
        improperReps++;
        if (!_stateSeq.contains('s3')) {
          currentStatus = "LOWER HIPS";
          currentColor = Colors.red;
          onSpeak("lower hips");
        } else {
          currentStatus = "Invalid Rep";
          currentColor = Colors.red;
          onSpeak("Invalid rep");
        }
      }
      _stateSeq.clear();
      _incorrectPosture = false;
    } else {
      if (state == 's2') _stage = "Down";
      if (state == 's3') _stage = "Deep";

      if (hipVertAngle > 50) {
        currentStatus = "BEND BACKWARDS";
        currentColor = Colors.red;
      } else if (hipVertAngle < 10 && _stateSeq.where((e) => e == 's2').length == 1) {
        currentStatus = "BEND FORWARD";
        currentColor = Colors.red;
      } else if (kneeVertAngle > 95) {
        currentStatus = "SQUAT TOO DEEP";
        currentColor = Colors.red;
        _incorrectPosture = true;
      }

      if (ankleVertAngle > 45) {
        currentStatus = "KNEE OVER TOE";
        currentColor = Colors.red;
        _incorrectPosture = true;
      }

      if (currentStatus != "Good Form") {
        onSpeak(currentStatus.trim().toLowerCase());
      }
    }

    return SquatAnalysisResult(
      reps: reps,
      improperReps: improperReps,
      stage: _stage,
      status: currentStatus,
      color: currentColor,
      hipVertAngle: hipVertAngle,
      kneeVertAngle: kneeVertAngle,
      ankleVertAngle: ankleVertAngle,
    );
  }
}
