import 'dart:collection';

import 'package:flutter/material.dart';

import 'pull_up_config.dart';
import 'pull_up_result.dart';

class PullUpStates {
  static const waitingForHang = 'waiting_for_hang';
  static const pullingUp = 'pulling_up';
  static const atTop = 'at_top';
  static const goingDown = 'going_down';
}

class PullUpAnalyzer {
  PullUpAnalyzer({PullUpConfig? config})
    : _config = config ?? const PullUpConfig();

  final PullUpConfig _config;

  int reps = 0;
  String state = PullUpStates.waitingForHang;

  int _hangStreak = 0;
  int _topStreak = 0;
  int _downStreak = 0;
  int _unevenStreak = 0;

  double? _prevElbowAvg;

  final Queue<double> _elbowHistL = Queue<double>();
  final Queue<double> _elbowHistR = Queue<double>();
  final Queue<double> _hipHist = Queue<double>();
  final Queue<double> _ankleXHist = Queue<double>();

  static const int _ankleSwingWindow = 12;

  PullUpAnalysisResult analyze({
    required double rawLeftElbow,
    required double rawRightElbow,
    required double rawHipAngle,
    required double midAnkleX,
    required double bodyLength,
    required double noseY,
    required double leftWristY,
    required double rightWristY,
    required bool noseVisible,
  }) {
    _pushSample(_elbowHistL, rawLeftElbow, _config.movingAvgWindow);
    _pushSample(_elbowHistR, rawRightElbow, _config.movingAvgWindow);
    _pushSample(_hipHist, rawHipAngle, _config.movingAvgWindow);
    _pushSample(_ankleXHist, midAnkleX, _ankleSwingWindow);

    final lElbow = _avg(_elbowHistL);
    final rElbow = _avg(_elbowHistR);
    final hipAngle = _avg(_hipHist);
    final elbowAvg = (lElbow + rElbow) / 2;

    final swingRange = _range(_ankleXHist);
    final swingThreshold = bodyLength * _config.ankleSwingRatio;
    final kipping =
        hipAngle < _config.hipStraightMin ||
        (swingRange > 0 && swingRange > swingThreshold);

    final uneven = (lElbow - rElbow).abs() > _config.unevenDiffThreshold;

    final wristY = leftWristY < rightWristY ? leftWristY : rightWristY;
    final chinAbove = noseVisible && noseY < wristY;

    double deltaElbow = 0.0;
    if (_prevElbowAvg != null) {
      deltaElbow = elbowAvg - _prevElbowAvg!;
    }
    _prevElbowAvg = elbowAvg;

    final goingDown = deltaElbow > 2.0;
    final goingUp = deltaElbow < -2.0;

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
      case PullUpStates.waitingForHang:
        if (elbowAvg >= _config.elbowBottomMin) {
          _hangStreak++;
          if (_hangStreak >= _config.streakFramesRequired) {
            state = PullUpStates.pullingUp;
            _hangStreak = 0;
          }
        } else {
          _hangStreak = 0;
        }
        setStatus('Hang with straight arms', Colors.white, false, 0);
        break;

      case PullUpStates.pullingUp:
        if (chinAbove && elbowAvg <= _config.elbowTopMax) {
          _topStreak++;
          if (_topStreak >= _config.streakFramesRequired) {
            state = PullUpStates.atTop;
            _topStreak = 0;
          }
        } else {
          _topStreak = 0;
        }

        if (goingDown && !(chinAbove && elbowAvg <= _config.elbowTopMax)) {
          _downStreak++;
          if (_downStreak >= _config.streakFramesRequired) {
            setStatus('Pull your chin over the bar.', Colors.red, true, 2);
            state = PullUpStates.waitingForHang;
            _prevElbowAvg = null;
            _downStreak = 0;
          }
        } else {
          _downStreak = 0;
        }

        if (state == PullUpStates.pullingUp) {
          if (kipping) {
            setStatus(
              'Keep your body straight, do not swing.',
              Colors.orange,
              true,
              1,
            );
          }

          if (uneven) {
            _unevenStreak++;
          } else {
            _unevenStreak = 0;
          }

          if (_unevenStreak >= _config.unevenStreakRequired) {
            setStatus('Pull evenly with both arms.', Colors.orange, true, 1);
          }

          if (!chinAbove && elbowAvg > _config.elbowHalfMin) {
            setStatus('Keep pulling up.', Colors.white, false, 0);
          }
        }
        break;

      case PullUpStates.atTop:
        _unevenStreak = 0;
        setStatus('Top reached', Colors.green, false, 0);
        if (goingDown && !chinAbove) {
          _downStreak++;
          if (_downStreak >= _config.streakFramesRequired) {
            state = PullUpStates.goingDown;
            _downStreak = 0;
          }
        } else {
          _downStreak = 0;
        }
        break;

      case PullUpStates.goingDown:
        _unevenStreak = 0;
        if (goingUp && elbowAvg < _config.elbowBottomMin) {
          setStatus('Extend your arms fully.', Colors.red, true, 2);
          state = PullUpStates.waitingForHang;
          _prevElbowAvg = null;
          _hangStreak = 0;
        } else if (elbowAvg >= _config.elbowBottomMin) {
          _hangStreak++;
          if (_hangStreak >= _config.streakFramesRequired) {
            reps++;
            state = PullUpStates.waitingForHang;
            _hangStreak = 0;
            setStatus('Rep counted', Colors.green, false, 0);
          }
        } else {
          _hangStreak = 0;
        }
        break;
    }

    return PullUpAnalysisResult(
      reps: reps,
      state: state,
      statusMessage: status,
      statusColor: statusColor,
      elbowAvg: elbowAvg,
      isBadForm: isBad,
    );
  }

  void reset() {
    reps = 0;
    state = PullUpStates.waitingForHang;
    _hangStreak = 0;
    _topStreak = 0;
    _downStreak = 0;
    _unevenStreak = 0;
    _prevElbowAvg = null;
    _elbowHistL.clear();
    _elbowHistR.clear();
    _hipHist.clear();
    _ankleXHist.clear();
  }

  void _pushSample(Queue<double> queue, double value, int maxLen) {
    queue.addLast(value);
    while (queue.length > maxLen) {
      queue.removeFirst();
    }
  }

  double _avg(Queue<double> values) {
    if (values.isEmpty) return 0.0;
    var sum = 0.0;
    for (final v in values) {
      sum += v;
    }
    return sum / values.length;
  }

  double _range(Queue<double> values) {
    if (values.isEmpty) return 0.0;
    var minVal = values.first;
    var maxVal = values.first;
    for (final v in values) {
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }
    return maxVal - minVal;
  }
}
