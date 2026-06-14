import 'package:flutter/material.dart';

class PlankConfig {
  const PlankConfig({this.smoothingFactor = 0.5});

  final double smoothingFactor;
}

class PlankAnalysisResult {
  const PlankAnalysisResult({
    required this.status,
    required this.color,
    required this.hipAngle,
    required this.kneeAngle,
    required this.elbowAngle,
    required this.isBad,
  });

  final String status;
  final Color color;
  final double hipAngle;
  final double kneeAngle;
  final double elbowAngle;
  final bool isBad;
}

class PlankAnalyzer {
  PlankAnalyzer({PlankConfig? config})
    : _config = config ?? const PlankConfig();

  final PlankConfig _config;

  double? _prevHip;
  double? _prevKnee;
  double? _prevElbow;

  PlankAnalysisResult analyze({
    required double rawHipAngle,
    required double rawKneeAngle,
    required double rawElbowAngle,
  }) {
    final s = _config.smoothingFactor;

    _prevHip ??= rawHipAngle;
    _prevKnee ??= rawKneeAngle;
    _prevElbow ??= rawElbowAngle;

    final hipAngle = _prevHip! * (1 - s) + rawHipAngle * s;
    final kneeAngle = _prevKnee! * (1 - s) + rawKneeAngle * s;
    final elbowAngle = _prevElbow! * (1 - s) + rawElbowAngle * s;

    _prevHip = hipAngle;
    _prevKnee = kneeAngle;
    _prevElbow = elbowAngle;

    final (status, color, isBad) = _getPlankStatus(
      hipAngle: hipAngle,
      kneeAngle: kneeAngle,
    );

    return PlankAnalysisResult(
      status: status,
      color: color,
      hipAngle: hipAngle,
      kneeAngle: kneeAngle,
      elbowAngle: elbowAngle,
      isBad: isBad,
    );
  }

  (String, Color, bool) _getPlankStatus({
    required double hipAngle,
    required double kneeAngle,
  }) {
    const good = Colors.green;
    const bad = Colors.red;

    if (kneeAngle < 150) {
      return ('Keep Knees Straight!', bad, true);
    }

    if (160 <= hipAngle && hipAngle <= 180) {
      return ('Perfect Form', good, false);
    } else if (hipAngle > 155) {
      return ('Hips Too Low! (Lift Hips)', bad, true);
    } else {
      return ('Hips Too High!', bad, true);
    }
  }

  void resetSmoothing() {
    _prevHip = null;
    _prevKnee = null;
    _prevElbow = null;
  }
}
