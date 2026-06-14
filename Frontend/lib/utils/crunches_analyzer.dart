import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';

import 'crunches_config.dart';
import 'crunches_result.dart';

class CrunchesStates {
  static const down = 'down';
  static const goingUp = 'going_up';
  static const up = 'up';
  static const goingDown = 'going_down';
}

class CrunchesAnalyzer {
  CrunchesAnalyzer({CrunchesConfig? config})
    : _config = config ?? const CrunchesConfig();

  final CrunchesConfig _config;

  int reps = 0;
  String state = CrunchesStates.down;

  double? _prevAngle;
  double? _baselineNeckDist;

  final Queue<double> _crunchHist = Queue<double>();

  CrunchesAnalysisResult analyze({
    required double shoulderHipKneeAngle,
    required double neckDist,
    required bool noseVisible,
  }) {
    _crunchHist.addLast(shoulderHipKneeAngle);
    while (_crunchHist.length > _config.movingAvgWindow) {
      _crunchHist.removeFirst();
    }

    final crunchAngle = _crunchHist.isEmpty
        ? 0.0
        : _crunchHist.reduce((a, b) => a + b) / _crunchHist.length;

    if (state == CrunchesStates.down && _baselineNeckDist == null) {
      _baselineNeckDist = neckDist;
    } else if (state == CrunchesStates.down && _baselineNeckDist != null) {
      _baselineNeckDist = (_baselineNeckDist! * 0.9) + (neckDist * 0.1);
    }

    if (_prevAngle == null) {
      _prevAngle = crunchAngle;
    }
    final delta = crunchAngle - _prevAngle!;
    _prevAngle = crunchAngle;

    final goingUp = delta < -_config.angleTrendThreshold;
    final goingDown = delta > _config.angleTrendThreshold;

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

    if (!noseVisible) {
      setStatus('Keep your face visible.', Colors.orange, false, 1);
    }

    switch (state) {
      case CrunchesStates.down:
        setStatus('Ready. Crunch up.', Colors.white, false, 0);
        if (crunchAngle < 100) {
          state = CrunchesStates.goingUp;
        }
        break;

      case CrunchesStates.goingUp:
        // Check for pulling neck
        if (_baselineNeckDist != null &&
            neckDist < _baselineNeckDist! * _config.neckPullThreshold) {
          setStatus("Don't pull your neck! Look up.", Colors.red, true, 2);
        } else if (crunchAngle <= _config.topCrunchMax) {
          state = CrunchesStates.up;
          setStatus('Hold and squeeze!', Colors.green, false, 1);
        } else if (goingDown && crunchAngle > _config.topCrunchMax) {
          setStatus(
            'Lift shoulders higher off the mat.',
            Colors.orange,
            true,
            1,
          );
          state = CrunchesStates.down;
        }
        break;

      case CrunchesStates.up:
        setStatus('Hold and squeeze!', Colors.green, false, 1);
        if (crunchAngle > 95) {
          state = CrunchesStates.goingDown;
        }
        break;

      case CrunchesStates.goingDown:
        if (crunchAngle >= _config.bottomFlatMin) {
          reps++;
          state = CrunchesStates.down;
          setStatus('Good rep!', Colors.green, false, 1);
        } else if (goingUp && crunchAngle < _config.bottomFlatMin) {
          setStatus('Go fully flat on the mat.', Colors.orange, true, 1);
          state = CrunchesStates.up;
        }
        break;
    }

    return CrunchesAnalysisResult(
      reps: reps,
      state: state,
      statusMessage: status,
      statusColor: statusColor,
      crunchAngle: crunchAngle,
      neckDist: neckDist,
      isBadForm: isBad,
    );
  }

  void reset() {
    reps = 0;
    state = CrunchesStates.down;
    _prevAngle = null;
    _baselineNeckDist = null;
    _crunchHist.clear();
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
