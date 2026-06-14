import 'package:flutter/material.dart';

class ShoulderPressConfig {
  const ShoulderPressConfig({
    this.smoothingFactor = 0.5,
    this.stageDownThreshold = 100, // elbow bent ~90
    this.stageUpThreshold = 150, // arm extended
    this.streakFramesRequired = 3,
    this.backArchThreshold = 30,
    this.elbowFlareMin = 60,
    this.elbowFlareMax = 110,
  });

  final double smoothingFactor;
  final double stageDownThreshold;
  final double stageUpThreshold;
  final int streakFramesRequired;
  final double backArchThreshold;
  final double elbowFlareMin;
  final double elbowFlareMax;
}

class ShoulderPressAnalysisResult {
  const ShoulderPressAnalysisResult({
    required this.status,
    required this.color,
    required this.reps,
    required this.stage,
    required this.lElbowAngle,
    required this.rElbowAngle,
    required this.torsoAngle,
    required this.isBad,
  });

  final String status;
  final Color color;
  final int reps;
  final String stage;
  final double lElbowAngle;
  final double rElbowAngle;
  final double torsoAngle;
  final bool isBad;
}

class ShoulderPressAnalyzer {
  ShoulderPressAnalyzer({ShoulderPressConfig? config})
    : _config = config ?? const ShoulderPressConfig();

  final ShoulderPressConfig _config;

  int reps = 0;
  String stage = 'down';
  int _upStreak = 0;
  int _downStreak = 0;

  double? _prevLElbow;
  double? _prevRElbow;
  double? _prevLAlignment;
  double? _prevRAlignment;
  double? _prevTorso;

  ShoulderPressAnalysisResult analyze({
    required double rawLElbow,
    required double rawRElbow,
    required double rawLAlignment,
    required double rawRAlignment,
    required double rawTorso,
  }) {
    final s = _config.smoothingFactor;

    _prevLElbow ??= rawLElbow;
    _prevRElbow ??= rawRElbow;
    _prevLAlignment ??= rawLAlignment;
    _prevRAlignment ??= rawRAlignment;
    _prevTorso ??= rawTorso;

    final lElbowAngle = _prevLElbow! * (1 - s) + rawLElbow * s;
    final rElbowAngle = _prevRElbow! * (1 - s) + rawRElbow * s;
    final lAlignment = _prevLAlignment! * (1 - s) + rawLAlignment * s;
    final rAlignment = _prevRAlignment! * (1 - s) + rawRAlignment * s;
    final torsoAngle = _prevTorso! * (1 - s) + rawTorso * s;

    _prevLElbow = lElbowAngle;
    _prevRElbow = rElbowAngle;
    _prevLAlignment = lAlignment;
    _prevRAlignment = rAlignment;
    _prevTorso = torsoAngle;

    final avgElbow = (lElbowAngle + rElbowAngle) / 2;

    // Rep Counting Logic
    if (avgElbow > _config.stageUpThreshold) {
      _upStreak++;
      _downStreak = 0;
      if (stage == 'down' && _upStreak >= _config.streakFramesRequired) {
        stage = 'up';
      }
    } else if (avgElbow < _config.stageDownThreshold) {
      _downStreak++;
      _upStreak = 0;
      if (stage == 'up' && _downStreak >= _config.streakFramesRequired) {
        stage = 'down';
        reps++;
      }
    } else {
      // Transition zone
    }

    final (status, color, isBad) = _getFormStatus(
      lElbowAngle: lElbowAngle,
      rElbowAngle: rElbowAngle,
      lAlignment: lAlignment,
      rAlignment: rAlignment,
      torsoAngle: torsoAngle,
      stage: stage,
    );

    return ShoulderPressAnalysisResult(
      status: status,
      color: color,
      reps: reps,
      stage: stage,
      lElbowAngle: lElbowAngle,
      rElbowAngle: rElbowAngle,
      torsoAngle: torsoAngle,
      isBad: isBad,
    );
  }

  (String, Color, bool) _getFormStatus({
    required double lElbowAngle,
    required double rElbowAngle,
    required double lAlignment,
    required double rAlignment,
    required double torsoAngle,
    required String stage,
  }) {
    if (180 - torsoAngle > _config.backArchThreshold) {
      return ("Don't Arch Back! Engage Core", Colors.red, true);
    }

    if (stage == 'up' || (lElbowAngle > 120 || rElbowAngle > 120)) {
      if (lAlignment < _config.elbowFlareMin ||
          rAlignment < _config.elbowFlareMin) {
        return ('Keep Elbows Back!', Colors.orange, true);
      }
      if (lAlignment > _config.elbowFlareMax ||
          rAlignment > _config.elbowFlareMax) {
        return ("Don't Flare Elbows Out!", Colors.orange, true);
      }
    }

    final angleDiff = (lElbowAngle - rElbowAngle).abs();
    if (angleDiff > 25) {
      return ('Uneven Arms! Balance Weight', Colors.orange, true);
    }

    return ('Perfect Form', Colors.green, false);
  }

  void reset() {
    reps = 0;
    stage = 'down';
    _upStreak = 0;
    _downStreak = 0;
    _prevLElbow = null;
    _prevRElbow = null;
    _prevLAlignment = null;
    _prevRAlignment = null;
    _prevTorso = null;
  }
}
