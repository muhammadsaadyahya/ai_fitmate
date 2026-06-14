import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';

import 'glute_bridges_config.dart';
import 'glute_bridges_result.dart';

class GluteBridgesStates {
  static const down = 'down';
  static const goingUp = 'going_up';
  static const up = 'up';
  static const goingDown = 'going_down';
}

class GluteBridgesAnalyzer {
  GluteBridgesAnalyzer({GluteBridgesConfig? config})
    : _config = config ?? const GluteBridgesConfig();

  final GluteBridgesConfig _config;

  int reps = 0;
  String state = GluteBridgesStates.down;

  double? _prevAngle;

  final Queue<double> _bridgeHist = Queue<double>();
  final Queue<double> _kneeHist = Queue<double>();

  GluteBridgesAnalysisResult analyze({
    required double shoulderHipKneeAngle,
    required double hipKneeAnkleAngle,
  }) {
    _bridgeHist.addLast(shoulderHipKneeAngle);
    while (_bridgeHist.length > _config.movingAvgWindow) {
      _bridgeHist.removeFirst();
    }

    final bridgeAngle = _bridgeHist.isEmpty
        ? 0.0
        : _bridgeHist.reduce((a, b) => a + b) / _bridgeHist.length;

    _kneeHist.addLast(hipKneeAnkleAngle);
    while (_kneeHist.length > _config.movingAvgWindow) {
      _kneeHist.removeFirst();
    }

    final kneeAngle = _kneeHist.isEmpty
        ? 0.0
        : _kneeHist.reduce((a, b) => a + b) / _kneeHist.length;

    if (_prevAngle == null) {
      _prevAngle = bridgeAngle;
    }
    final delta = bridgeAngle - _prevAngle!;
    _prevAngle = bridgeAngle;

    final goingUp = delta > _config.angleTrendThreshold;
    final goingDown = delta < -_config.angleTrendThreshold;

    String status = 'Waiting...';
    Color statusColor = Colors.white;
    bool isBad = false;
    int priority = 0;

    void setStatus(String message, Color color, bool bad, int nextPriority) {
      if (nextPriority >= priority) {
        status = message;
        statusColor = color;
        isBad = bad;
        priority = nextPriority;
      }
    }

    switch (state) {
      case GluteBridgesStates.down:
        setStatus('Ready. Lift hips.', Colors.white, false, 0);
        if (bridgeAngle > _config.leaveFloorMin) {
          state = GluteBridgesStates.goingUp;
        }
        break;

      case GluteBridgesStates.goingUp:
        if (bridgeAngle >= _config.upMin) {
          state = GluteBridgesStates.up;
          setStatus('Squeeze glutes!', Colors.green, false, 1);
        } else if (goingDown && bridgeAngle < _config.upMin) {
          setStatus('Drive your hips higher!', Colors.orange, true, 1);
          state = GluteBridgesStates.down;
        }
        break;

      case GluteBridgesStates.up:
        // Form checks while at the top
        if (bridgeAngle > _config.hyperextendMax) {
          setStatus(
            'Don\'t arch your back! Keep it straight.',
            Colors.red,
            true,
            3,
          );
        } else if (kneeAngle > _config.footTooFarAngle) {
          setStatus(
            'Feet too far out! Move them closer to you.',
            Colors.red,
            true,
            2,
          );
        } else if (kneeAngle < _config.footTooCloseAngle) {
          setStatus(
            'Feet too close! Move them away slightly.',
            Colors.red,
            true,
            2,
          );
        } else {
          setStatus('Hold and squeeze glutes!', Colors.green, false, 1);
        }

        if (bridgeAngle < _config.dropDownMax) {
          state = GluteBridgesStates.goingDown;
        }
        break;

      case GluteBridgesStates.goingDown:
        if (bridgeAngle <= _config.downMax) {
          reps++;
          state = GluteBridgesStates.down;
          setStatus('Good rep!', Colors.green, false, 1);
        } else if (goingUp && bridgeAngle > _config.downMax) {
          setStatus(
            'Lower your hips completely to the floor.',
            Colors.orange,
            true,
            1,
          );
          state = GluteBridgesStates.up;
        }
        break;
    }

    return GluteBridgesAnalysisResult(
      reps: reps,
      state: state,
      statusMessage: status,
      statusColor: statusColor,
      bridgeAngle: bridgeAngle,
      kneeAngle: kneeAngle,
      isBadForm: isBad,
    );
  }

  void reset() {
    reps = 0;
    state = GluteBridgesStates.down;
    _prevAngle = null;
    _bridgeHist.clear();
    _kneeHist.clear();
  }

  static double calculateAngle(List<double> a, List<double> b, List<double> c) {
    final radians =
        atan2(c[1] - b[1], c[0] - b[0]) - atan2(a[1] - b[1], a[0] - b[0]);
    var angle = (radians * 180.0 / pi).abs();
    if (angle > 180.0) {
      angle = 360 - angle;
    }
    return angle;
  }

  static double euclideanDist(List<double> p1, List<double> p2) {
    return sqrt(
      (p1[0] - p2[0]) * (p1[0] - p2[0]) + (p1[1] - p2[1]) * (p1[1] - p2[1]),
    );
  }
}
