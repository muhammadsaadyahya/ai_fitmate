import 'package:flutter/material.dart';

class LateralRaiseConfig {
  const LateralRaiseConfig({
    this.smoothingFactor = 0.5,
    this.stageDownThreshold = 35,
    this.stageUpThreshold = 80,
    this.streakFramesRequired = 3,
    this.tooHighThreshold = 105,
    this.elbowBentThreshold = 145,
    this.backSwingThreshold = 20,
    this.bentOverThreshold = 160,
    this.asymmetryThreshold = 20,
    this.checkFormHeightThreshold = 50,
  });

  final double smoothingFactor;
  final double stageDownThreshold;
  final double stageUpThreshold;
  final int streakFramesRequired;
  final double tooHighThreshold;
  final double elbowBentThreshold;
  final double backSwingThreshold;
  final double bentOverThreshold;
  final double asymmetryThreshold;
  final double checkFormHeightThreshold;
}

class LateralRaiseAnalysisResult {
  const LateralRaiseAnalysisResult({
    required this.status,
    required this.color,
    required this.reps,
    required this.stage,
    required this.lElevation,
    required this.rElevation,
    required this.torsoAngle,
    required this.isBad,
  });

  final String status;
  final Color color;
  final int reps;
  final String stage;
  final double lElevation;
  final double rElevation;
  final double torsoAngle;
  final bool isBad;
}

class LateralRaiseAnalyzer {
  LateralRaiseAnalyzer({LateralRaiseConfig? config})
    : _config = config ?? const LateralRaiseConfig();

  final LateralRaiseConfig _config;

  int reps = 0;
  String stage = 'down';
  int _upStreak = 0;
  int _downStreak = 0;

  double? _prevLElev;
  double? _prevRElev;
  double? _prevLForm;
  double? _prevRForm;
  double? _prevTorso;

  LateralRaiseAnalysisResult analyze({
    required double rawLElev,
    required double rawRElev,
    required double rawLForm,
    required double rawRForm,
    required double rawTorso,
  }) {
    final s = _config.smoothingFactor;

    _prevLElev ??= rawLElev;
    _prevRElev ??= rawRElev;
    _prevLForm ??= rawLForm;
    _prevRForm ??= rawRForm;
    _prevTorso ??= rawTorso;

    final lElev = _prevLElev! * (1 - s) + rawLElev * s;
    final rElev = _prevRElev! * (1 - s) + rawRElev * s;
    final lForm = _prevLForm! * (1 - s) + rawLForm * s;
    final rForm = _prevRForm! * (1 - s) + rawRForm * s;
    final torsoAngle = _prevTorso! * (1 - s) + rawTorso * s;

    _prevLElev = lElev;
    _prevRElev = rElev;
    _prevLForm = lForm;
    _prevRForm = rForm;
    _prevTorso = torsoAngle;

    // Rep Counting Logic
    final avgElev = (lElev + rElev) / 2;

    if (avgElev > _config.stageUpThreshold) {
      _upStreak++;
      _downStreak = 0;
      if (stage == 'down' && _upStreak >= _config.streakFramesRequired) {
        stage = 'up';
      }
    } else if (avgElev < _config.stageDownThreshold) {
      _downStreak++;
      _upStreak = 0;
      if (stage == 'up' && _downStreak >= _config.streakFramesRequired) {
        stage = 'down';
        reps++;
      }
    } else {
      _upStreak = 0;
      _downStreak = 0;
    }

    final (status, color, isBad) = _getFormStatus(
      lElev: lElev,
      rElev: rElev,
      lForm: lForm,
      rForm: rForm,
      torsoAngle: torsoAngle,
    );

    return LateralRaiseAnalysisResult(
      status: status,
      color: color,
      reps: reps,
      stage: stage,
      lElevation: lElev,
      rElevation: rElev,
      torsoAngle: torsoAngle,
      isBad: isBad,
    );
  }

  (String, Color, bool) _getFormStatus({
    required double lElev,
    required double rElev,
    required double lForm,
    required double rForm,
    required double torsoAngle,
  }) {
    final maxElev = lElev > rElev ? lElev : rElev;
    final minElev = lElev < rElev ? lElev : rElev;

    if (torsoAngle < 160) {
      return ('Keep torso upright and still!', Colors.orange, true);
    }

    if (maxElev > _config.tooHighThreshold) {
      return ('Too High! Stop at Shoulders', Colors.red, true);
    }

    if ((maxElev - minElev) > _config.asymmetryThreshold && maxElev > 40) {
      return ('Keep Arms Even!', Colors.orange, true);
    }

    final checkLeft = lElev > _config.checkFormHeightThreshold;
    final checkRight = rElev > _config.checkFormHeightThreshold;

    final leftArmBad = checkLeft && (lForm < _config.elbowBentThreshold);
    final rightArmBad = checkRight && (rForm < _config.elbowBentThreshold);

    if (leftArmBad || rightArmBad) {
      return ('Straighten Arms!', Colors.red, true);
    }

    if (stage == 'down' && maxElev > 45 && maxElev < _config.stageUpThreshold) {
      return ("Keep Raising...", Colors.white, false);
    }

    if (stage == 'up' && maxElev < 70 && maxElev > _config.stageDownThreshold) {
      return ("Lower Completely...", Colors.white, false);
    }

    if (stage == 'up') {
      return ("Good Height! Hold...", Colors.green, false);
    }

    return ('Good Form', Colors.green, false);
  }

  void reset() {
    reps = 0;
    stage = 'down';
    _upStreak = 0;
    _downStreak = 0;
    _prevLElev = null;
    _prevRElev = null;
    _prevLForm = null;
    _prevRForm = null;
    _prevTorso = null;
  }
}
