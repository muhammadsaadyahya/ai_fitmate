import 'package:flutter/material.dart';

class PushupConfig {
  const PushupConfig({
    this.movingAvgWindow = 5,
    this.upThreshold = 160,
    this.downThreshold = 90,
    this.streakFramesRequired = 3,
    this.kneeStraightThreshold = 150,
    this.bodyStraightGoodMin = 165,
    this.hipLineOffsetPx = 18,
    this.hipLineOffsetRatio = 0.05,
  });

  final int movingAvgWindow;
  final double upThreshold;
  final double downThreshold;
  final int streakFramesRequired;
  final double kneeStraightThreshold;
  final double bodyStraightGoodMin;
  final double hipLineOffsetPx;
  final double hipLineOffsetRatio;
}

class PushupAnalysisResult {
  const PushupAnalysisResult({
    required this.status,
    required this.color,
    required this.reps,
    required this.stage,
    required this.elbowAngle,
    required this.bodyAngle,
    required this.kneeAngle,
    required this.isBad,
  });

  final String status;
  final Color color;
  final int reps;
  final String stage;
  final double elbowAngle;
  final double bodyAngle;
  final double kneeAngle;
  final bool isBad;
}

class PushupAnalyzer {
  PushupAnalyzer({PushupConfig? config})
    : _config = config ?? const PushupConfig();

  final PushupConfig _config;

  int reps = 0;
  String stage = 'up';
  int _upStreak = 0;
  int _downStreak = 0;

  final List<double> _elbowHist = [];
  final List<double> _bodyHist = [];
  final List<double> _kneeHist = [];

  double _getAverage(List<double> hist) {
    if (hist.isEmpty) return 180.0;
    return hist.reduce((a, b) => a + b) / hist.length;
  }

  void _updateHistory(List<double> hist, double value) {
    hist.add(value);
    if (hist.length > _config.movingAvgWindow) {
      hist.removeAt(0);
    }
  }

  PushupAnalysisResult analyze({
    required double rawElbowAngle,
    required double rawBodyAngle,
    required double rawKneeAngle,
    required double expectedHipY,
    required double actualHipY,
    required double bodyLength,
  }) {
    _updateHistory(_elbowHist, rawElbowAngle);
    _updateHistory(_bodyHist, rawBodyAngle);
    _updateHistory(_kneeHist, rawKneeAngle);

    final elbowAngle = _getAverage(_elbowHist);
    final bodyAngle = _getAverage(_bodyHist);
    final kneeAngle = _getAverage(_kneeHist);

    // Rep Counting Logic
    if (elbowAngle >= _config.upThreshold) {
      _upStreak++;
      _downStreak = 0;
      if (stage == 'down' && _upStreak >= _config.streakFramesRequired) {
        stage = 'up';
        reps++;
      }
    } else if (elbowAngle <= _config.downThreshold) {
      _downStreak++;
      _upStreak = 0;
      if (stage == 'up' && _downStreak >= _config.streakFramesRequired) {
        stage = 'down';
      }
    }

    // Dynamic Hip Threshold
    final ratioPart = _config.hipLineOffsetRatio * bodyLength;
    final dynamicHipOffset = _config.hipLineOffsetPx > ratioPart
        ? _config.hipLineOffsetPx
        : ratioPart;

    final (status, color, isBad) = _getFormStatus(
      elbowAngle: elbowAngle,
      bodyAngle: bodyAngle,
      kneeAngle: kneeAngle,
      stage: stage,
      actualHipY: actualHipY,
      expectedHipY: expectedHipY,
      dynamicHipOffset: dynamicHipOffset,
    );

    return PushupAnalysisResult(
      status: status,
      color: color,
      reps: reps,
      stage: stage,
      elbowAngle: elbowAngle,
      bodyAngle: bodyAngle,
      kneeAngle: kneeAngle,
      isBad: isBad,
    );
  }

  (String, Color, bool) _getFormStatus({
    required double elbowAngle,
    required double bodyAngle,
    required double kneeAngle,
    required String stage,
    required double actualHipY,
    required double expectedHipY,
    required double dynamicHipOffset,
  }) {
    const good = Colors.green;
    const warn = Colors.orange;
    const bad = Colors.red;

    if (kneeAngle < _config.kneeStraightThreshold) {
      return ('Keep Knees Straight!', bad, true);
    }

    if (bodyAngle < _config.bodyStraightGoodMin) {
      final offset = actualHipY - expectedHipY;
      if (offset > dynamicHipOffset)
        return ("Raise Hips (Don't Sag)", bad, true);
      if (offset < -dynamicHipOffset)
        return ("Lower Hips (Don't Pike)", bad, true);
      return ('Keep Body Straight', warn, true);
    }

    if (stage == 'down' && elbowAngle > (_config.downThreshold + 15)) {
      return ('Go Lower', warn, true);
    }
    if (stage == 'up' && elbowAngle < (_config.upThreshold - 10)) {
      return ('Extend Arms', warn, true);
    }

    return ('Good Form', good, false);
  }

  void reset() {
    reps = 0;
    stage = 'up';
    _upStreak = 0;
    _downStreak = 0;
    _elbowHist.clear();
    _bodyHist.clear();
    _kneeHist.clear();
  }
}
