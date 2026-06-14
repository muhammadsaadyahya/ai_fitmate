import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';

import 'triceps_dips_config.dart';
import 'triceps_dips_result.dart';

class TricepsDipsStates {
  static const up = 'up';
  static const goingDown = 'going_down';
  static const down = 'down';
  static const goingUp = 'going_up';
}

class TricepsDipsAnalyzer {
  TricepsDipsAnalyzer({TricepsDipsConfig? config})
    : _config = config ?? const TricepsDipsConfig();

  final TricepsDipsConfig _config;

  int reps = 0;
  String state = TricepsDipsStates.up;

  int _downStreak = 0;
  int _upStreak = 0;
  double? _prevElbow;
  double? _baselineNeckDist;

  final Queue<double> _elbowHist = Queue<double>();

  TricepsDipsAnalysisResult analyze({
    required double shoulderElbowWristAngle,
    required double neckDist,
    required double torsoAngle,
    required double hipWristXDist,
    required double shoulderHipDist,
  }) {
    _elbowHist.addLast(shoulderElbowWristAngle);
    while (_elbowHist.length > _config.movingAvgWindow) {
      _elbowHist.removeFirst();
    }

    final elbowAngle = _elbowHist.isEmpty
        ? 0.0
        : _elbowHist.reduce((a, b) => a + b) / _elbowHist.length;

    if (state == TricepsDipsStates.up && _baselineNeckDist == null) {
      _baselineNeckDist = neckDist;
    } else if (state == TricepsDipsStates.up && _baselineNeckDist != null) {
      _baselineNeckDist = (_baselineNeckDist! * 0.9) + (neckDist * 0.1);
    }

    if (_prevElbow == null) {
      _prevElbow = elbowAngle;
    }
    final delta = elbowAngle - _prevElbow!;
    _prevElbow = elbowAngle;

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

    // Posture checks (ordered by severity)
    bool postureError = false;

    // 1. Extreme Danger: Shoulder below elbow (checked elsewhere, skip for now)
    // 2. Shrugging
    if (_baselineNeckDist != null && neckDist < _baselineNeckDist! * 0.7) {
      setStatus('Don\'t shrug! Keep shoulders down.', Colors.red, true, 3);
      postureError = true;
    }
    // 3. Hips drifting
    else if (hipWristXDist > (shoulderHipDist * 0.5)) {
      setStatus('Keep your hips close to the bench!', Colors.red, true, 2);
      postureError = true;
    }
    // 4. Torso leaning
    else if (torsoAngle > 30) {
      setStatus('Keep your back straight!', Colors.orange, true, 1);
      postureError = true;
    }

    if (!postureError) {
      if (state == TricepsDipsStates.up) {
        setStatus('Lower into the dip.', Colors.white, false, 0);
        if (elbowAngle < _config.topLockoutSoft) {
          _downStreak++;
          if (_downStreak >= _config.streakFramesRequired) {
            state = TricepsDipsStates.goingDown;
            _downStreak = 0;
          }
        } else {
          _downStreak = 0;
        }
      } else if (state == TricepsDipsStates.goingDown) {
        if (elbowAngle <= _config.bottomTargetMax) {
          state = TricepsDipsStates.down;
          setStatus('Push up!', Colors.green, false, 0);
        } else if (goingUp && elbowAngle > _config.bottomTargetMax) {
          setStatus(
            'Go lower! Target a 90-degree bend.',
            Colors.orange,
            true,
            1,
          );
          state = TricepsDipsStates.up;
        }
      } else if (state == TricepsDipsStates.down) {
        setStatus('Drive up.', Colors.white, false, 0);
        if (elbowAngle > _config.bottomStartUp) {
          _upStreak++;
          if (_upStreak >= _config.streakFramesRequired) {
            state = TricepsDipsStates.goingUp;
            _upStreak = 0;
          }
        } else {
          _upStreak = 0;
        }
      } else if (state == TricepsDipsStates.goingUp) {
        if (elbowAngle >= _config.topLockoutMin) {
          reps++;
          state = TricepsDipsStates.up;
          setStatus('Good rep!', Colors.green, false, 0);
        } else if (goingDown && elbowAngle < _config.topLockoutSoft) {
          setStatus('Lock out your arms at the top.', Colors.orange, true, 1);
          state = TricepsDipsStates.down;
        }
      }
    }

    return TricepsDipsAnalysisResult(
      reps: reps,
      state: state,
      statusMessage: status,
      statusColor: statusColor,
      elbowAngle: elbowAngle,
      isBadForm: isBad,
    );
  }

  void reset() {
    reps = 0;
    state = TricepsDipsStates.up;
    _downStreak = 0;
    _upStreak = 0;
    _prevElbow = null;
    _baselineNeckDist = null;
    _elbowHist.clear();
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
